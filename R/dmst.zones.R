#' Determine zones using the dynamic minimum spanning tree scan test of Assuncao et al. (2006)
#'
#' \code{dmst.zones} determines the zones that produce the largest test statistic using a greedy algorithm.  Specifically, starting individually with each region as a starting zone, new (connected) regions are added to the current zone in the order that results in the largest likelihood ratio test statistic.  This is used to implement the dynamic minimum spanning tree (dmst) scan test of Assuncao et al. (2006).
#'
#' The test is performed using the spatial scan test based on the Poisson test statistic and a fixed number of cases.  The first cluster is the most likely to be a cluster.  If no significant clusters are found, then the most likely cluster is returned (along with a warning).
#'
#' Every zone considered must have a total population less than \code{ubpop * sum(pop)}.  Additionally, the maximum intercentroid distance for the regions within a zone must be no more than \code{ubd * the maximum intercentroid distance across all regions}.
#'
#' @inheritParams dmst.test
#' @param maxonly A logical value indicating whether to return only the maximum test statistic across all candidate zones.  Default is \code{FALSE}.

#' @return Returns a list of zones to consider for clustering that includes the location id of each zone and the associated test statistic, number of cases, expected number of cases, and the population in the zone. If \code{maxonly = TRUE}, then only the maximum test statistic across all of these zones is returned.
#' @author Joshua French
#' @importFrom matrixStats colMaxs
#' @importFrom utils head
#' @references Assuncao, R.M., Costa, M.A., Tavares, A. and Neto, S.J.F. (2006). Fast detection of arbitrarily shaped disease clusters, Statistics in Medicine, 25, 723-742.
#'
#' @export
#' @examples
#' data(nydf)
#' data(nyw)
#' coords = as.matrix(nydf[,c("longitude", "latitude")])
#' # find zone with max statistic starting from each individual region
#' max_zones = dmst.zones(coords, cases = floor(nydf$cases),
#'                        nydf$pop, w = nyw, ubpop = 0.25,
#'                        ubd = .25, lonlat = TRUE)
#' head(max_zones)

# data(nydf)
# data(nyw)
# coords = nydf[,c("longitude", "latitude")]
# cases = floor(nydf$cases)
# pop = nydf$population
# w = nyw
# e = sum(cases)/sum(pop)*pop
# ubpop = 0.5
# ubd = 0.5
# lonlat = TRUE
# parallel = FALSE
# maxonly = TRUE

dmst.zones = function(coords, cases, pop, w, ex = sum(cases)/sum(pop)*pop, ubpop = 0.5, ubd = 1, lonlat = FALSE, parallel = FALSE, maxonly = FALSE)
{
  # sanity checking
  arg_check_dmst_zones(coords, cases, pop, w, ex, ubpop, ubd, lonlat, parallel)
  
  # setup various arguments and such
  ty = sum(cases)   # total number of cases
  # intercentroid distances
  d = sp::spDists(as.matrix(coords), longlat = lonlat)
  # upperbound for population in zone
  max_pop = ubpop *sum(pop)
  # upperbound for distance between centroids in zone
  max_dist = ubd * max(d)
  # find all neighbors from each starting zone within distance upperbound
  all_neighbors = lapply(seq_along(cases), function(i) which(d[i,] <= max_dist))
  # should only max be returned, or a pruned version
  type = ifelse(maxonly, "maxonly", "pruned")
  
  # set up finding zones with max stat from each starting region
  fcall = lapply
  if (parallel) fcall = parallel::mclapply
  fcall_list = list(X = as.list(seq_along(all_neighbors)), FUN = function(i){
    # find zone with max stat, starting from each region
    dmst_max_zone(i, all_neighbors[[i]], cases, pop, w, ex, ty, max_pop, type = type)
  })

  # obtain list of zones with maximum statistic from each starting region (or the max statistic)
  max_zones = do.call(fcall, fcall_list)
  
  # return max statistic or the max statistic zones
  if(maxonly){
    return(max(unlist(max_zones)))
  }else{
    return(max_zones)
  }
}

arg_check_dmst_zones = function(coords, cases, pop, w, ex, ubpop, ubd, lonlat, parallel)
{
  if(ncol(coords) != 2) stop("coords should have 2 columns")
  if(nrow(coords) != length(cases)) stop("nrow(coords) != length(cases)")
  if(length(cases) != length(pop)) stop('length(cases) != length(pop)')
  if(length(cases) != nrow(w)) stop('length(cases) != nrow(w)')
  if(length(cases) != length(ex)) stop('length(cases) != length(ex)')
  if(length(ubpop) != 1 | !is.numeric(ubpop)) stop("ubpop should be a single number")
  if(ubpop <= 0 | ubpop > 1) stop("ubpop not in (0, 1]")
  if(length(ubd) != 1 | !is.numeric(ubd)) stop("ubd should be a single number")
  if(ubd <= 0 | ubd > 1) stop("ubd not in (0, 1]")
  if(length(lonlat) != 1 || !is.logical(lonlat)) stop("lonlat must be a single logical value")
  if(length(parallel) != 1 || !is.logical(parallel)) stop("parallel must be a single logical value")
}