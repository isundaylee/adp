URLS = [
  'http://adphi.mit.edu/brothers/muses/',
  'http://adphi.mit.edu/brothers/atlas/',
  'http://adphi.mit.edu/brothers/celeritas/',
  'http://adphi.mit.edu/brothers/pendulum/',
  'http://adphi.mit.edu/brothers/prodromos/'
]

OUTPUT = 'output'

require 'fileutils'
require 'nokogiri'
require 'open-uri'

def sanitize_filename(filename)
  # Split the name when finding a period which is preceded by some
  # character, and is followed by some character other than a period,
  # if there is no following period that is followed by something
  # other than a period (yeah, confusing, I know)
  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

  # We now have one or two parts (depending on whether we could find
  # a suitable period). For each of these parts, replace any unwanted
  # sequence of characters with an underscore
  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

  # Finally, join the parts with a period and return the result
  return fn.join '.'
end

def fetch_url(url)
  puts 'Processing ' + url

  name = url.split('/')[-1].strip
  dir = File.join(OUTPUT, name)

  FileUtils.mkdir_p(dir)

  index = Nokogiri::HTML(open(url).read)

  index.css('.et_pt_portfolio_item').each do |c|
    bname = c.at_css('.et_pt_portfolio_title').text

    bfname = "#{sanitize_filename(bname)}.jpeg"

    File.write(File.join(dir, bfname), open(c.at_css('.et_pt_portfolio_image img')['src'].strip).read)
  end
end

URLS.each { |u| fetch_url(u) }