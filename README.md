# Seam

Simple workflows in Ruby. 

## Usage

Seam is meant for situations where you want to take some entity (user, order, ec.) through a long-running process that is comprised of multiple steps.

For example, if you want every new user a "hello" email after signup, then wait a few days, and then send a "gone so soon?" email if they haven't signed in again.

This gem provides some simple tools for building and executing this process.
It provides a way to define the process, break it up into separate components, and then send entities through the process.

####Define a workflow####

To start, define a workflow.

````
flow = Seam::Flow.new
flow.send_order_to_warehouse
flow.wait_for_order_to_be_shipped wait_up_to: 7.days
flow.send_shipping_email email_template: 'shipping_7'
flow.mark_order_as_fulfilled
````

A flow will convert any method call you make into a step that has to be completed. 

You can also pass a hash to the method, which will be saved for later.

````
flow.wait_for_order_to_be_shipped wait_up_to: 7.days
````

####Starting an instance of the flow####

Starting an instance of the flow is done with "start":

````
flow.start order_id: '1234'
````

An instance of this effort was created and saved in whatever persistence is being used (in-memory by default). 

This effort will start at the first step (send_order_to_warehouse) and then progress through the steps as they are completed.

"start" also returns the effort that was created, and it will look like this:

````
<Seam::Effort 
  @completed_steps=[], 
  @history=[], 
  @complete=false, 
  @id="1ecc4cbe-16af-45f6-8532-7f37493ec11c", 
  @created_at=2013-08-20 22:58:07 -0500, 
  @next_execute_at=2013-08-20 22:58:07 -0500, 
  @next_step="send_order_to_warehouse", 
  @flow={"steps"=>[{"name"=>"send_order_to_warehouse", "type"=>"do", "arguments"=>{}}, {"name"=>"wait_for_order_to_be_shipped", "type"=>"do", "arguments"=>{}}, {"name"=>"send_shipping_email", "type"=>"do", "arguments"=>{}}, {"name"=>"mark_order_as_fulfilled", "type"=>"do", "arguments"=>{}}]}, 
  @data={"order_id"=>"1234"}>
````

So we have a unique instance of this flow and the instance has been saved in the database.  The first step to be executed for this instance is "send_order_to_warehouse", so let's create a worker for this step.

####Defining workers for each step####

A workflow is comprised of steps, and each step needs a worker.  Each worker will execute whatever it was meant to do, and then either:

1. Pass the workflow instance to the next step on the process, or
2. Delay the step execution for a later date, or
3. End the entire workflow process for the instance.

Since send_order_to_warehouse is the first step in this workflow, let's build the worker for it first:

````
class SendOrderToWarehouseWorker < Seam::Worker
  def process
    # the current workflow instance is available as "effort"
    order = Order.find effort.data['order_id']
    warehouse_service.send order

    # by default, if this worker completes with no error the workflow instance will be sent to the next step
  end
end
````

If you name your class as a camel-case version of the step, Seam will automatically bind up the worker to the step.  

To execute the worker, use:

````
SendOrderToWarehouse.execute_all
````

This method will look for all workflow instances that are currently ready for the step in question.

####Progressing through the workflow####

By default, steps are considered as being completed when the worker completes successfully.  There might be times where you don't want to go quickly, like the next step in this example:

````
class WaitForOrderToBeShippedWorker < Seam::Worker
  def process
    effort.data["shipping_status"] = # some method that returns the shipping status
    unless effort.data["shipping_status"] == "shipped"
      try_again_in 4.hours
    end
  end
end
````

"try_again_in" can be used to signal that the step has not been completed and should be retried later.

"eject" can also be used to signify that the entire workflow should be stopped, like so:

````
class WaitForOrderToBeShippedWorker < Seam::Worker
  def process
    effort.data["shipping_status"] = # some method that returns the shipping status
    if effort.data["shipping_status"] == "cancelled"
      eject # no need to continue!
    end
  end
end
````

####History####

As workflow instances progress through each step, the history of every operation will be stored.  A history of the "data" block before and after each step run is also stored.

The history is available through:

````
effort.history
````

####Waiting####

Seam comes with a default worker for waiting. It can be defined by calling "wait" on a flow, like this.

````
flow = Seam::Flow.new
flow.send_order_to_warehouse
flow.wait 2.days
flow.check_if_the_order_has_been_fulfilled
````

## Installation

Add this line to your application's Gemfile:

    gem 'seam'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seam

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
