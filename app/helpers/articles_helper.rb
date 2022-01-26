module ArticlesHelper
    def return_date(datetime)
        datetime.strftime("%B %e, %Y")
    end
end
