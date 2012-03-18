class CreateCurrencyData < ActiveRecord::Migration
  def self.up
    Currency.create({
        :id=>1,
        :country_code=>"US",
        :name=>"US Dollars",
        :format=>"%u%n",
        :sign=> "$",
        :separator=> ".",
        :delimiter=> ",",
        :paypal_currency_code=> "USD"
    })
    
    Currency.create({
        :id=>2,
        :country_code=>"GB",
        :name=>"Pounds",
        :format=>"%u%n",
        :sign=> "&pound",
        :separator=> ",",
        :delimiter=> ".",
        :paypal_currency_code=> "GBP"
    })
    
    Currency.create({
        :id=>3,
        :country_code=>"TH",
        :name=>"Baht",
        :format=>"%n %u",
        :sign=> "baht",
        :separator=> ".",
        :delimiter=> ",",
        :paypal_currency_code=> "THB"
    })

  end

  def self.down
  end
end
