# Prior/Likelihood/Posterior plots, plp

plp <- function( mapfit , prob=0.9 , ... ) {
    
    if ( !(class(mapfit) %in% c("map","map2stan")) ) {
        stop( "Requires model fit of class map or map2stan" )
    }
    is_m2s <- FALSE
    if ( class(mapfit)=="map2stan" ) is_m2s <- TRUE
    
    post <- extract.samples(mapfit)
    form <- mapfit@formula
    
    # use start list to get parameter names
    pars <- names(mapfit@start)
    priors <- list()
    
    # discover priors for each parameter
    for ( i in 1:length(form) ) {
        f <- form[[i]]
        if ( as.character(f[[1]]) == "~" ) {
            f <- eval(f)
            par <- as.character(f[[2]])
            if ( par %in% pars ) {
                # a prior
                priors[[par]] <- f[[3]]
            }
        } # if ~
    } #i
    
    # now compute quantiles from priors
    # as specified by prob and median (0.5)
    p <- c( (1-prob)/2 , 0.5 , 1-(1-prob)/2 )
    for ( i in 1:length(priors) ) {
        dname <- as.character(priors[[i]][[1]])
        qname <- dname
        substr(qname,1,1) <- "q"
        arglist <- list( p )
        for ( j in 2:length(priors[[i]]) ) {
            arglist[[length(arglist)+1]] <- priors[[i]][[j]]
        }
        q <- do.call( qname , arglist )
        priors[[i]] <- q
    }
    
    # if map fit, use quadratic approximation to get posterior quantiles
    post <- priors
    if ( is_m2s==FALSE ) {
        for ( i in 1:length(post) ) {
            par <- names(post)[i]
            post[[par]][2] <- coef(mapfit)[par]
            ci <- post[[par]][2] + c(-1,1)*se(mapfit)[par]*qnorm(p[3],0,1)
            post[[par]][1] <- ci[1]
            post[[par]][3] <- ci[2]
        }
    }
    
    # finally, likelihood as quotient post/prior
    lik <- post
    for ( i in 1:length(lik) ) {
        
    }
    
    
    list(priors,post)
    
}


#EXAMPLES/TESTS
if (FALSE) {

library(rethinking)
data(chimpanzees)
d <- chimpanzees

flist4 <- alist(
    pulled.left ~ dbinom( 1 , p ),
    logit(p) <- a + b*prosoc.left ,
    a ~ dnorm(0,1),
    b ~ dnorm(0,1)
)

m <- map( flist4 , data=d , start=list(a=0,b=0) )



}
