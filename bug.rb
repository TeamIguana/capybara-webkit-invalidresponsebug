require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'sinatra/base'
require 'capybara/dsl'
require 'capybara/webkit'

class SplashPageJsAcceptanceTest < Test::Unit::TestCase
  include Capybara::DSL

  def test_sometimes_explodes
    request_to_target=nil
    splash_url = '/test_splash'
    target_url = '/target_link.html'

    app = Sinatra.new do
      get splash_url do
        <<-HTML
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Title</title>
        </head>
        <body>
        <script type="text/javascript" language="javascript">//<![CDATA[
         setTimeout(function(){}, 2000);
         setTimeout(function(){window.location.replace("#{target_url}");},1000);
        //]]>
        </script>
        </body>
        </html>
        HTML
      end

      get target_url do
        request_to_target=env
        'target'
      end
    end

    test_app_with_javascript(app)
    visit splash_url
    wait_for_redirect

    assert_equal(target_url, current_uri.request_uri.to_s)
    assert_equal("http://#{request_to_target['HTTP_HOST']}#{splash_url}", request_to_target['HTTP_REFERER'])
  end

  def test_app_with_javascript(app)
    Capybara.app = app
    Capybara.default_driver = :webkit_debug
  end

  def wait_for_redirect
    sleep(4)
  end

  def current_uri
    URI.parse(current_url)
  end
end