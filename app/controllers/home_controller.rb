class HomeController < ApplicationController
  def index
    loc = Geocoder.search(request.ip)
    if loc.length then
      loc = loc.first
      @default_loc = "#{loc.city}, #{loc.region_code}".strip
      @default_loc = "San Francisco, CA" if @default_loc.length == 1
    else
      @default_loc = "San Francisco, CA"
    end
  end

  def search
    Geocoder::Configuration.lookup = :yahoo
    query = params[:query] || ""
    near = params[:near] || ""
    count = params[:count] || "20"

    query.strip!
    near.strip!
    count.strip!

    empty = query == "" and near == ""

    @count = count.to_i
    @count = 10 if @count < 10
    @count = 100 if @count > 100

    if near == nil or near.strip.length == 0 then
      #logger.info "Searching IP address #{request.ip}"
      loc = Geocoder.search(request.ip)
    else
      #logger.info "Searching for #{near}"
      loc = Geocoder.search(near)
    end

    if loc.length then
      loc = loc.first
      logger.info "#{loc}"
      @default_loc = "#{loc.city}".strip
      @default_loc = "San Francisco" if @default_loc.length == 0
    else
      @default_loc = "San Francisco"
    end

    loc = Geocoder.search(@default_loc).first
    @loc = loc
    begin
      near = loc.city
    rescue
      near = "San Francisco"
    end
    puts "#{loc}"
    
    if not empty
      tank = IndexTank::Client.new ''
      idx = tank.indexes 'eightylegs'

      query_str = ""
      query_str += "#{query}" if query != ""

      @results = idx.search query_str,
                          :fetch => 'docid,url,subject,text,location,timestamp,timestr',
                          :function => 6,
                          :var0 => loc.latitude,
                          :var1 => loc.longitude,
                          :len => @count,
                          :fetch_variables => true,
                          :fetch_categories => true,
                          :filter_function6 => '*:0'

      logger.info "query: #{query_str}; near #{loc.city} => #{loc.latitude},#{loc.longitude}; len #{@count}; ip #{request.ip}"

      @nresults_total = @results['results'].length
      @results
    else
      @results = {"results" => [], "matches" => -1}
    end
  end

  def maps
    self.search
  end
end
