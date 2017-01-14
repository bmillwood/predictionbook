cache("sitemap", expires_in: 12.hours) do

  xml.instruct!
	xml.urlset("xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9") do

    # TODO: Grab the Prediction last updated at date in controller

    xml.url do |sitemap_url|
      sitemap_url.loc(root_url)
      sitemap_url.changefreq("weekly")
      sitemap_url.lastmod(w3c_date(Prediction.maximum(:updated_at)))
    end

    xml.url do |sitemap_url|
      sitemap_url.loc(predictions_url)
      sitemap_url.changefreq("weekly")
      sitemap_url.lastmod(w3c_date(Prediction.maximum(:updated_at)))
    end

    xml.url do |sitemap_url|
      sitemap_url.loc(happenstance_path)
      sitemap_url.changefreq("weekly")
      sitemap_url.lastmod(w3c_date(Prediction.maximum(:updated_at)))
    end

    xml.url do |sitemap_url|
      sitemap_url.loc(recent_predictions_url)
      sitemap_url.changefreq("weekly")
      sitemap_url.lastmod(w3c_date(Prediction.maximum(:updated_at)))
    end

    xml.url do |sitemap_url|
      sitemap_url.loc(unjudged_predictions_url)
      sitemap_url.changefreq("weekly")
      sitemap_url.lastmod(w3c_date(Prediction.maximum(:updated_at)))
    end

    xml.url do |sitemap_url|
      sitemap_url.loc(judged_predictions_url)
      sitemap_url.changefreq("weekly")
      sitemap_url.lastmod(w3c_date(Prediction.maximum(:updated_at)))
    end

    xml.url do |sitemap_url|
      sitemap_url.loc(future_predictions_url)
      sitemap_url.changefreq("weekly")
      sitemap_url.lastmod(w3c_date(Prediction.maximum(:updated_at)))
    end

    # TODO: List out all publication predictions:

	end

end
