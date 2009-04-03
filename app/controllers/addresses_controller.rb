class AddressesController < ApplicationController
  def fetch_cities
    @cities = Province.find(params[:parent_id]).cities
    @counties = @cities.first.counties
    @areas = @counties.first.areas
    render :partial => 'children', :locals => { :which => 'cities'}
  end
  
  def fetch_counties
    @counties = City.find(params[:parent_id]).counties
    @areas = @counties.first.areas
    render :partial => 'children', :locals => { :which => 'counties'}
  end
  
  def fetch_areas
    @areas = County.find(params[:parent_id]).areas
    render :partial => 'children', :locals => { :which => 'areas'}
  end
end
