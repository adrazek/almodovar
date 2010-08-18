require 'spec_helper'

feature "Navigating included documents" do
  
  scenario "Accesing included data" do
    stub_auth_request(:get, "http://movida.example.com/people/1").to_return(:body => <<-XML)
      <person>
        <name>Pedro Almodóvar</name>
        <extra-data type="document">
          <films type="array">
            <film>
              <title>¿Qué he hecho yo para merecer esto?</title>
              <year type="integer">1984</year>
            </film>
            <film>
              <title>Mujeres al borde de un ataque de nervios</title>
              <year type="integer">1988</year>
            </film>
          </films>
        </extra-data>
      </person>
    XML
  
    person = Almodovar::Resource("http://movida.example.com/people/1", auth)
  
    person.name.should == "Pedro Almodóvar"
    person.extra_data.films[0].title.should == "¿Qué he hecho yo para merecer esto?"
    person.extra_data.films[0].year.should  == 1984
    person.extra_data.films[1].title.should == "Mujeres al borde de un ataque de nervios"
    person.extra_data.films[1].year.should  == 1988
  end
  
end