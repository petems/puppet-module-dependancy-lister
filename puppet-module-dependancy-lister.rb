#!/opt/puppetlabs/puppet/bin/ruby

require 'net/https'
require 'uri'
require 'json'
require 'optparse'

RED        = "\e[31m"
      # Set the terminal's foreground ANSI color to green.
GREEN      = "\e[32m"
# Set the terminal's foreground ANSI color to yellow.
YELLOW     = "\e[33m"
# Set the terminal's foreground ANSI color to blue.
BLUE       = "\e[34m"

CLEAR      = "\e[0m"


class ForgeModule
  attr_accessor :name, :version, :found, :depr, :deps

  def initialize
    @name    = ''
    @version = ''
    @found   = true
    @depr    = false
    @deps    = []
  end

  def return_line(mod)
    return "mod '#{mod.name}', '#{mod.version}'"
  end
end

class ForgeVersions

  attr_accessor :mods_read, :lines, :data

  def initialize
    @mods_read  = []
    @lines      = []
    @data       = {}
  end

  def get_mod_name(mod)
    if mod =~ /^\s*mod\s+('|")(\w+[\/-]\w+)('|"),\s+\S+/
      return $2
    elsif mod =~ /^\s*mod\s+('|")(\w+[\/-]\w+)('|")$/
      return $2
    end
  end

  def warn_depr(mod)
    return "#{RED} Warning: #{mod} is deprecated #{CLEAR}"
  end

  def warn_nf(mod)
    return "#{RED} Warning: #{mod} was not found #{CLEAR}"
  end

  def pretty_print_deps(original_module, deps)
    answer_string = []
    deps.each do | module_dep |
      answer_string << "Module #{original_module} has Dependancy: #{module_dep["name"]} #{module_dep["version_requirement"]} "
    end
    answer_string
  end

  def is_depr?(ver)
    ver == '999.999.999'
  end

  def mod_exists?(mod, data)
    o = false
    data.each do |d|
      o = (d.name == mod)
      break if (o == true)
    end
    return o
  end


  def read_puppetfile(input)
    mods_read = []
    lines = []
    # Read modules from Puppetfile
    file_in = File.open(input, "r") do |fh|
      fh.each_line do |line|
        line.chomp!
        name = get_mod_name(line)
        if name
          mods_read.push(name) unless mods_read.include? name
        else
          lines.push(line)
        end
      end
    end
    return mods_read, lines
  end

  # Arg: Array with list of modules 'author/name'
  # Ret: Array of ForgeModule objects
  def load_modules(mods)
    data = []
    # Search retrieved modules
    mods.each do |mod|
      _mod = mod.gsub(/\//,'-')
      m = ForgeModule.new
      m, data = findModuleData(_mod, data)
      data.push(m) unless mod_exists?(_mod,data)
    end
    return data
  end

  # Arg: String containing name of module 'author/name'
  # Ret: ForgeModule object populated
  def findModuleData(mod, data)
    m = ForgeModule.new
    m.name = mod
    url = "https://forgeapi.puppet.com:443/v3/modules/#{mod}"
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => 'test'})
    response = http.request(request)

    if response.code == '200'
      parsed = JSON.parse(response.body)
      if parsed["current_release"] != nil
        m.found = true
        m.version = parsed["current_release"]["version"]
        deps = parsed["current_release"]["metadata"]["dependencies"]
        if deps.any?
          puts pretty_print_deps(mod, deps)
        end
        if is_depr?(parsed["current_release"]["version"])
          puts warn_depr(mod)
        end
      else
        puts warn_nf(mod)
      end
    else
      puts warn_nf(mod)
    end
    return m, data
  end
end

# Methods needed to get args and pretty print the objects
def parse_options()
  # Get arguments from CLI
  options = {}
  help = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0}"
    opts.on('-i [/path/to/original/Puppetfile]', '--input [/path/to/original/Puppetfile', "Path to original Puppetfile") do |i|
      options[:input] = i
    end
    opts.on('-h', '--help', 'Display this help') do
      puts opts
      exit
    end
  end
  help.parse!
  return options, help
end

def validate_options(options, help)
  # Validate arguments
  input = options[:input]
  output = options[:output] || 'Puppetfile'
  outdir = File.dirname(output)

  unless input
    puts "ERROR: input is a mandatory argument"
    puts help
    exit 2
  end

  unless File.file?(input)
    puts "ERROR: #{input} does not exist"
    puts help
    exit 2
  end

  return input
end

# Set variables
options, help = parse_options()
input, output, outdir = validate_options(options, help)
f = ForgeVersions.new

f.mods_read, f.lines = f.read_puppetfile(input)
f.data = f.load_modules(f.mods_read)
# Now I have an array of modules

exit 0

