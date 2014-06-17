namespace :importer do
  task :periodic => :environment do
    Mapping.where(active: true).each do |mapping|
      Resque.enqueue OdkToSalesforce::Dispatcher, mapping.id, 250
    end
  end
end