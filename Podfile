xcodeproj 'CCListViewExample/CCListViewExample.xcodeproj/'

target "CCListViewExample" do
	if ENV['TRAVIS']
		pod "CCListView", :path => ENV['TRAVIS_BUILD_DIR']
	else
	    pod "CCListView", :path => "./"
	end
    pod "FLKAutoLayout"
end
