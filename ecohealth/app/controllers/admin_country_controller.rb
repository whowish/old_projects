class AdminCountryController < AdminController
  def add
    country = Country.new()
    country.name = params[:name]
    country.save
    render :json=>{:ok=>true,:country_view=> render_to_string(:partial=>"/admin_country/country_unit",:locals=>{:country=>country})}
  end
  
  def edit
    country = Country.first(:conditions=>{:id=>params[:id]})
    country.name = params[:name]
    country.save
    render :json=>{:ok=>true}
  end
  
  def delete
    country = Country.first(:conditions=>{:id=>params[:id]})
    country.destroy
    render :json=>{:ok=>true}
  end
  
end
