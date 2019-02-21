class TestsController < Simpler::Controller

  def index
    @time = Time.now
  end

  def create

  end

  def show
    @test = Test.find(id: params[:id])
  end

  def plain
    render plain: 'This is plain render'
  end

  def inline
    @time = Time.now
    render inline: '<h1>This is inline render</h1><p><%= @time %></p>'
  end
end
