class Countries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string "name", :null => false
      t.string "code", :null => false
    end    
    
    Country.create({:name=>"Andorra",:code=>"AD"})
    Country.create({:name=>"United Arab Emirates",:code=>"AE"})
    Country.create({:name=>"Afghanistan",:code=>"AF"})
    Country.create({:name=>"Antigua & Barbuda",:code=>"AG"})
    Country.create({:name=>"Anguilla",:code=>"AI"})
    Country.create({:name=>"Albania",:code=>"AL"})
    Country.create({:name=>"Armenia",:code=>"AM"})
    Country.create({:name=>"Netherlands Antilles",:code=>"AN"})
    Country.create({:name=>"Angola",:code=>"AO"})
    Country.create({:name=>"Antarctica",:code=>"AQ"})
    Country.create({:name=>"Argentina",:code=>"AR"})
    Country.create({:name=>"American Samoa",:code=>"AS"})
    Country.create({:name=>"Austria",:code=>"AT"})
    Country.create({:name=>"Australia",:code=>"AU"})
    Country.create({:name=>"Aruba",:code=>"AW"})
    Country.create({:name=>"Azerbaijan",:code=>"AZ"})
    Country.create({:name=>"Bosnia and Herzegovina",:code=>"BA"})
    Country.create({:name=>"Barbados",:code=>"BB"})
    Country.create({:name=>"Bangladesh",:code=>"BD"})
    Country.create({:name=>"Belgium",:code=>"BE"})
    Country.create({:name=>"Burkina Faso",:code=>"BF"})
    Country.create({:name=>"Bulgaria",:code=>"BG"})
    Country.create({:name=>"Bahrain",:code=>"BH"})
    Country.create({:name=>"Burundi",:code=>"BI"})
    Country.create({:name=>"Benin",:code=>"BJ"})
    Country.create({:name=>"Bermuda",:code=>"BM"})
    Country.create({:name=>"Brunei Darussalam",:code=>"BN"})
    Country.create({:name=>"Bolivia",:code=>"BO"})
    Country.create({:name=>"Brazil",:code=>"BR"})
    Country.create({:name=>"Bahama",:code=>"BS"})
    Country.create({:name=>"Bhutan",:code=>"BT"})
    Country.create({:name=>"Burma (no longer exists)",:code=>"BU"})
    Country.create({:name=>"Bouvet Island",:code=>"BV"})
    Country.create({:name=>"Botswana",:code=>"BW"})
    Country.create({:name=>"Belarus",:code=>"BY"})
    Country.create({:name=>"Belize",:code=>"BZ"})
    Country.create({:name=>"Canada",:code=>"CA"})
    Country.create({:name=>"Cocos (Keeling) Islands",:code=>"CC"})
    Country.create({:name=>"Central African Republic",:code=>"CF"})
    Country.create({:name=>"Congo",:code=>"CG"})
    Country.create({:name=>"Switzerland",:code=>"CH"})
    Country.create({:name=>"Côte D'ivoire (Ivory Coast)",:code=>"CI"})
    Country.create({:name=>"Cook Iislands",:code=>"CK"})
    Country.create({:name=>"Chile",:code=>"CL"})
    Country.create({:name=>"Cameroon",:code=>"CM"})
    Country.create({:name=>"China",:code=>"CN"})
    Country.create({:name=>"Colombia",:code=>"CO"})
    Country.create({:name=>"Costa Rica",:code=>"CR"})
    Country.create({:name=>"Czechoslovakia (no longer exists)",:code=>"CS"})
    Country.create({:name=>"Cuba",:code=>"CU"})
    Country.create({:name=>"Cape Verde",:code=>"CV"})
    Country.create({:name=>"Christmas Island",:code=>"CX"})
    Country.create({:name=>"Cyprus",:code=>"CY"})
    Country.create({:name=>"Czech Republic",:code=>"CZ"})
    Country.create({:name=>"German Democratic Republic (no longer exists)",:code=>"DD"})
    Country.create({:name=>"Germany",:code=>"DE"})
    Country.create({:name=>"Djibouti",:code=>"DJ"})
    Country.create({:name=>"Denmark",:code=>"DK"})
    Country.create({:name=>"Dominica",:code=>"DM"})
    Country.create({:name=>"Dominican Republic",:code=>"DO"})
    Country.create({:name=>"Algeria",:code=>"DZ"})
    Country.create({:name=>"Ecuador",:code=>"EC"})
    Country.create({:name=>"Estonia",:code=>"EE"})
    Country.create({:name=>"Egypt",:code=>"EG"})
    Country.create({:name=>"Western Sahara",:code=>"EH"})
    Country.create({:name=>"Eritrea",:code=>"ER"})
    Country.create({:name=>"Spain",:code=>"ES"})
    Country.create({:name=>"Ethiopia",:code=>"ET"})
    Country.create({:name=>"Finland",:code=>"FI"})
    Country.create({:name=>"Fiji",:code=>"FJ"})
    Country.create({:name=>"Falkland Islands (Malvinas)",:code=>"FK"})
    Country.create({:name=>"Micronesia",:code=>"FM"})
    Country.create({:name=>"Faroe Islands",:code=>"FO"})
    Country.create({:name=>"France",:code=>"FR"})
    Country.create({:name=>"France, Metropolitan",:code=>"FX"})
    Country.create({:name=>"Gabon",:code=>"GA"})
    Country.create({:name=>"United Kingdom (Great Britain)",:code=>"GB"})
    Country.create({:name=>"Grenada",:code=>"GD"})
    Country.create({:name=>"Georgia",:code=>"GE"})
    Country.create({:name=>"French Guiana",:code=>"GF"})
    Country.create({:name=>"Ghana",:code=>"GH"})
    Country.create({:name=>"Gibraltar",:code=>"GI"})
    Country.create({:name=>"Greenland",:code=>"GL"})
    Country.create({:name=>"Gambia",:code=>"GM"})
    Country.create({:name=>"Guinea",:code=>"GN"})
    Country.create({:name=>"Guadeloupe",:code=>"GP"})
    Country.create({:name=>"Equatorial Guinea",:code=>"GQ"})
    Country.create({:name=>"Greece",:code=>"GR"})
    Country.create({:name=>"South Georgia and the South Sandwich Islands",:code=>"GS"})
    Country.create({:name=>"Guatemala",:code=>"GT"})
    Country.create({:name=>"Guam",:code=>"GU"})
    Country.create({:name=>"Guinea-Bissau",:code=>"GW"})
    Country.create({:name=>"Guyana",:code=>"GY"})
    Country.create({:name=>"Hong Kong",:code=>"HK"})
    Country.create({:name=>"Heard & McDonald Islands",:code=>"HM"})
    Country.create({:name=>"Honduras",:code=>"HN"})
    Country.create({:name=>"Croatia",:code=>"HR"})
    Country.create({:name=>"Haiti",:code=>"HT"})
    Country.create({:name=>"Hungary",:code=>"HU"})
    Country.create({:name=>"Indonesia",:code=>"ID"})
    Country.create({:name=>"Ireland",:code=>"IE"})
    Country.create({:name=>"Israel",:code=>"IL"})
    Country.create({:name=>"India",:code=>"IN"})
    Country.create({:name=>"British Indian Ocean Territory",:code=>"IO"})
    Country.create({:name=>"Iraq",:code=>"IQ"})
    Country.create({:name=>"Islamic Republic of Iran",:code=>"IR"})
    Country.create({:name=>"Iceland",:code=>"IS"})
    Country.create({:name=>"Italy",:code=>"IT"})
    Country.create({:name=>"Jamaica",:code=>"JM"})
    Country.create({:name=>"Jordan",:code=>"JO"})
    Country.create({:name=>"Japan",:code=>"JP"})
    Country.create({:name=>"Kenya",:code=>"KE"})
    Country.create({:name=>"Kyrgyzstan",:code=>"KG"})
    Country.create({:name=>"Cambodia",:code=>"KH"})
    Country.create({:name=>"Kiribati",:code=>"KI"})
    Country.create({:name=>"Comoros",:code=>"KM"})
    Country.create({:name=>"St. Kitts and Nevis",:code=>"KN"})
    Country.create({:name=>"Korea, Democratic People's Republic of",:code=>"KP"})
    Country.create({:name=>"Korea, Republic of",:code=>"KR"})
    Country.create({:name=>"Kuwait",:code=>"KW"})
    Country.create({:name=>"Cayman Islands",:code=>"KY"})
    Country.create({:name=>"Kazakhstan",:code=>"KZ"})
    Country.create({:name=>"Lao People's Democratic Republic",:code=>"LA"})
    Country.create({:name=>"Lebanon",:code=>"LB"})
    Country.create({:name=>"Saint Lucia",:code=>"LC"})
    Country.create({:name=>"Liechtenstein",:code=>"LI"})
    Country.create({:name=>"Sri Lanka",:code=>"LK"})
    Country.create({:name=>"Liberia",:code=>"LR"})
    Country.create({:name=>"Lesotho",:code=>"LS"})
    Country.create({:name=>"Lithuania",:code=>"LT"})
    Country.create({:name=>"Luxembourg",:code=>"LU"})
    Country.create({:name=>"Latvia",:code=>"LV"})
    Country.create({:name=>"Libyan Arab Jamahiriya",:code=>"LY"})
    Country.create({:name=>"Morocco",:code=>"MA"})
    Country.create({:name=>"Monaco",:code=>"MC"})
    Country.create({:name=>"Moldova, Republic of",:code=>"MD"})
    Country.create({:name=>"Madagascar",:code=>"MG"})
    Country.create({:name=>"Marshall Islands",:code=>"MH"})
    Country.create({:name=>"Mali",:code=>"ML"})
    Country.create({:name=>"Mongolia",:code=>"MN"})
    Country.create({:name=>"Myanmar",:code=>"MM"})
    Country.create({:name=>"Macau",:code=>"MO"})
    Country.create({:name=>"Northern Mariana Islands",:code=>"MP"})
    Country.create({:name=>"Martinique",:code=>"MQ"})
    Country.create({:name=>"Mauritania",:code=>"MR"})
    Country.create({:name=>"Monserrat",:code=>"MS"})
    Country.create({:name=>"Malta",:code=>"MT"})
    Country.create({:name=>"Mauritius",:code=>"MU"})
    Country.create({:name=>"Maldives",:code=>"MV"})
    Country.create({:name=>"Malawi",:code=>"MW"})
    Country.create({:name=>"Mexico",:code=>"MX"})
    Country.create({:name=>"Malaysia",:code=>"MY"})
    Country.create({:name=>"Mozambique",:code=>"MZ"})
    Country.create({:name=>"Namibia",:code=>"NA"})
    Country.create({:name=>"New Caledonia",:code=>"NC"})
    Country.create({:name=>"Niger",:code=>"NE"})
    Country.create({:name=>"Norfolk Island",:code=>"NF"})
    Country.create({:name=>"Nigeria",:code=>"NG"})
    Country.create({:name=>"Nicaragua",:code=>"NI"})
    Country.create({:name=>"Netherlands",:code=>"NL"})
    Country.create({:name=>"Norway",:code=>"NO"})
    Country.create({:name=>"Nepal",:code=>"NP"})
    Country.create({:name=>"Nauru",:code=>"NR"})
    Country.create({:name=>"Neutral Zone (no longer exists)",:code=>"NT"})
    Country.create({:name=>"Niue",:code=>"NU"})
    Country.create({:name=>"New Zealand",:code=>"NZ"})
    Country.create({:name=>"Oman",:code=>"OM"})
    Country.create({:name=>"Panama",:code=>"PA"})
    Country.create({:name=>"Peru",:code=>"PE"})
    Country.create({:name=>"French Polynesia",:code=>"PF"})
    Country.create({:name=>"Papua New Guinea",:code=>"PG"})
    Country.create({:name=>"Philippines",:code=>"PH"})
    Country.create({:name=>"Pakistan",:code=>"PK"})
    Country.create({:name=>"Poland",:code=>"PL"})
    Country.create({:name=>"St. Pierre & Miquelon",:code=>"PM"})
    Country.create({:name=>"Pitcairn",:code=>"PN"})
    Country.create({:name=>"Puerto Rico",:code=>"PR"})
    Country.create({:name=>"Portugal",:code=>"PT"})
    Country.create({:name=>"Palau",:code=>"PW"})
    Country.create({:name=>"Paraguay",:code=>"PY"})
    Country.create({:name=>"Qatar",:code=>"QA"})
    Country.create({:name=>"Réunion",:code=>"RE"})
    Country.create({:name=>"Romania",:code=>"RO"})
    Country.create({:name=>"Russian Federation",:code=>"RU"})
    Country.create({:name=>"Rwanda",:code=>"RW"})
    Country.create({:name=>"Saudi Arabia",:code=>"SA"})
    Country.create({:name=>"Solomon Islands",:code=>"SB"})
    Country.create({:name=>"Seychelles",:code=>"SC"})
    Country.create({:name=>"Sudan",:code=>"SD"})
    Country.create({:name=>"Sweden",:code=>"SE"})
    Country.create({:name=>"Singapore",:code=>"SG"})
    Country.create({:name=>"St. Helena",:code=>"SH"})
    Country.create({:name=>"Slovenia",:code=>"SI"})
    Country.create({:name=>"Svalbard & Jan Mayen Islands",:code=>"SJ"})
    Country.create({:name=>"Slovakia",:code=>"SK"})
    Country.create({:name=>"Sierra Leone",:code=>"SL"})
    Country.create({:name=>"San Marino",:code=>"SM"})
    Country.create({:name=>"Senegal",:code=>"SN"})
    Country.create({:name=>"Somalia",:code=>"SO"})
    Country.create({:name=>"Suriname",:code=>"SR"})
    Country.create({:name=>"Sao Tome & Principe",:code=>"ST"})
    Country.create({:name=>"Union of Soviet Socialist Republics (no longer exists)",:code=>"SU"})
    Country.create({:name=>"El Salvador",:code=>"SV"})
    Country.create({:name=>"Syrian Arab Republic",:code=>"SY"})
    Country.create({:name=>"Swaziland",:code=>"SZ"})
    Country.create({:name=>"Turks & Caicos Islands",:code=>"TC"})
    Country.create({:name=>"Chad",:code=>"TD"})
    Country.create({:name=>"French Southern Territories",:code=>"TF"})
    Country.create({:name=>"Togo",:code=>"TG"})
    Country.create({:name=>"Thailand",:code=>"TH"})
    Country.create({:name=>"Tajikistan",:code=>"TJ"})
    Country.create({:name=>"Tokelau",:code=>"TK"})
    Country.create({:name=>"Turkmenistan",:code=>"TM"})
    Country.create({:name=>"Tunisia",:code=>"TN"})
    Country.create({:name=>"Tonga",:code=>"TO"})
    Country.create({:name=>"East Timor",:code=>"TP"})
    Country.create({:name=>"Turkey",:code=>"TR"})
    Country.create({:name=>"Trinidad & Tobago",:code=>"TT"})
    Country.create({:name=>"Tuvalu",:code=>"TV"})
    Country.create({:name=>"Taiwan, Province of China",:code=>"TW"})
    Country.create({:name=>"Tanzania, United Republic of",:code=>"TZ"})
    Country.create({:name=>"Ukraine",:code=>"UA"})
    Country.create({:name=>"Uganda",:code=>"UG"})
    Country.create({:name=>"United States Minor Outlying Islands",:code=>"UM"})
    Country.create({:name=>"United States of America",:code=>"US"})
    Country.create({:name=>"Uruguay",:code=>"UY"})
    Country.create({:name=>"Uzbekistan",:code=>"UZ"})
    Country.create({:name=>"Vatican City State (Holy See)",:code=>"VA"})
    Country.create({:name=>"St. Vincent & the Grenadines",:code=>"VC"})
    Country.create({:name=>"Venezuela",:code=>"VE"})
    Country.create({:name=>"British Virgin Islands",:code=>"VG"})
    Country.create({:name=>"United States Virgin Islands",:code=>"VI"})
    Country.create({:name=>"Viet Nam",:code=>"VN"})
    Country.create({:name=>"Vanuatu",:code=>"VU"})
    Country.create({:name=>"Wallis & Futuna Islands",:code=>"WF"})
    Country.create({:name=>"Samoa",:code=>"WS"})
    Country.create({:name=>"Democratic Yemen (no longer exists)",:code=>"YD"})
    Country.create({:name=>"Yemen",:code=>"YE"})
    Country.create({:name=>"Mayotte",:code=>"YT"})
    Country.create({:name=>"Yugoslavia",:code=>"YU"})
    Country.create({:name=>"South Africa",:code=>"ZA"})
    Country.create({:name=>"Zambia",:code=>"ZM"})
    Country.create({:name=>"Zaire",:code=>"ZR"})
    Country.create({:name=>"Zimbabwe",:code=>"ZW"})
    Country.create({:name=>"Unknown or unspecified country",:code=>"ZZ"})

  end

  def self.down
      drop_table :traces
  end
end