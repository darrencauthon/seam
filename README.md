# Seam

Simple workflows in Ruby. 

## Usage

Seam is meant for situations where you want to take some entity (user, order, ec.) through a long-running process.
This gem provides some basic tools to define the process, break it up into separate components and workers, and then send entities through it.

To start, define a workflow.  This is called a "flow" in this gem.

````
flow = Seam::Flow.new
flow.send_order_to_warehouse
flow.wait_for_order_to_be_shipped
flow.send_shipping_email
flow.mark_order_as_fulfilled
````

A flow will convert any method call you make into a step that has to be completed. 

Now that the process has been defined, you can create instances of it by starting the flow:

````

flow.start order_id: '1234'

````

What just happened?

An instance of this effort was created and saved. This effort will start at the first step (send_order_to_warehouse) and then progress through the steps as they are completed.

_(By default, Seam persists all data in memory, but there are other plugins available for other databases.)_

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

So we have an instance of this flow, and the next step to complete for it is "send_order_to_warehouse".  Let's create a worker for this step.

````
class SendOrderToWarehouse < Seam::Worker
  def process
    # Insert code to send the email. 
    # The original data used to create the effort can be accessed by "effort.data"
  end
end
````

If you name your class as a camel-case version of the step, Seam will automatically bind up the worker to the step.  

To execute the worker, use:

````
SendOrderToWarehouse.execute_all
````

All efforts sitting on this step will be passed through the worker.




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
