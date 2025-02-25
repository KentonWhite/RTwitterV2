# ' @title: RTweetV2 Function handling data as a data frame in R

#' This function is a sub function parsing the data returned from the API
#' @param results_data list with results from the API call

#' @return data frame
#' @export
#'

#' @import httr httpuv RCurl ROAuth data.table readr
#' @importFrom purrr map
##################################################################################################
# Parse get_users_v2 Data
##################################################################################################
data_parser_users <- function(results_data){


  du <- lapply(results_data,flattenlist)
  du <- purrr::map(du, as.data.table)
  du <- data.table::rbindlist(du, fill = TRUE)
  du <- as.data.frame(du)
  ## Remove cols we have no use for
  h <- grep("\\.start$|\\.end$", names(du), value = T)
  du <- du[ , !names(du) %in% h]

  ## entities description_hashtags
  h <- grep("entities\\.description\\.hashtags\\d+\\.tag|entities\\.description\\.hashtags\\.tag", names(du), value = T)
  if(length(h) != 0){
    du$description_hashtags <- combine_list_columns_tweets(h = h, dt = du)
    du$description_hashtags <- as.character(du$description_hashtags)
    du <- du[ , !names(du) %in% h]
  }

  ## entities description_mentions
  h <- grep("entities\\.description\\.mentions\\d+\\.username|entities\\.description\\.mentions\\.username", names(du), value = T)
  if(length(h) != 0){
    du$description_mentions <- combine_list_columns_tweets(h = h, dt = du)
    du$description_mentions <- as.character(du$description_mentions)
    du <- du[ , !names(du) %in% h]
  }

  ## url expanded
  h <- grep("entities\\.url\\.urls\\d+\\.expanded_url|entities\\.url\\.urls\\.expanded_url", names(du), value = T)
  if(length(h) != 0){
    du$url_expanded_url <- combine_list_columns_tweets(h = h, dt = du)
    du$url_expanded_url <- as.character(du$url_expanded_url)
    du <- du[ , !names(du) %in% h]
  }

  ## url_display
  h <- grep("entities\\.url\\.urls\\d+\\.display_url|entities\\.url\\.urls\\.display_url", names(du), value = T)
  if(length(h) != 0){
    du$url_display_url <- combine_list_columns_tweets(h = h, dt = du)
    du$url_display_url <- as.character(du$url_display_url)
    du <- du[ , !names(du) %in% h]
  }

  ## description expanded urls
  h <- grep("entities\\.description\\.urls\\d+\\.expanded_url|entities\\.description\\.urls\\.expanded_url", names(du), value = T)
  if(length(h) != 0){
    du$urls_description_expanded_url <- combine_list_columns_tweets(h = h, dt = du)
    du$urls_description_expanded_url <- as.character(du$urls_description_expanded_url)
    du <- du[ , !names(du) %in% h]
  }

  ## description display urls
  h <- grep("entities\\.description\\.urls\\d+\\.display_url|entities\\.description\\.urls\\.display_url", names(du), value = T)
  if(length(h) != 0){
    du$urls_description_display_url <- combine_list_columns_tweets(h = h, dt = du)
    du$urls_description_display_url <- as.character(du$urls_description_display_url)
    du <- du[ , !names(du) %in% h]
  }

  h <- grep("entities\\.url\\.urls\\d+\\url|entities\\.url\\.urls\\.url", names(du), value = T)
  if(length(h) != 0){
    du$url_urls_url <- combine_list_columns_tweets(h = h, dt = du)
    du$url_urls_url <- as.character(du$url_urls_url)
    du <- du[ , !names(du) %in% h]
  }

  h <- grep("entities\\.", names(du), value = T)
  if(length(h) != 0){
    du <- du[ , !names(du) %in% h]
  }

  ## get columns names right:
  names(du)[names(du)=="username"] <- "screen_name"
  names(du)[names(du)=="name"] <- "name"
  names(du)[names(du)=="id"] <- "user_id"
  names(du)[names(du)=="created_at"] <- "account_created_at"
  colnames_new <- gsub("public_metrics.","",names(du))
  colnames(du) <- colnames_new

  du <- du[ , order(names(du))]

  return(du)
}
