require 'spec_helper'

describe 'routes for the project controller' do
  it 'routes /projects/:id/build' do
    { :get => "/projects/1/build" }.should route_to(
      :controller => "projects",
      :action => "build",
      :project_id => "1")
  end
end