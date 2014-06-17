#' Survey a Fish Population
#'
#' Sample a simulated population of pelagic fish (created with \code{\link{SimFish}}) with down-looking acoustics (cross-lake, west-to-east) 
#' and midwater trawls (west-to-east)
#'
#' @param SimPop	 	A list with elements \code{LakeInfo}, \code{FishInfo}, \code{FishParam}, \code{FishPop}, typically output from \code{\link{SimFish}}.
#' See \code{\link{SimFish}} for details on the list elements.
#' @param NumEvents 	An integer scalar, number of sampling events, i.e., number of times to repeat the survey.
#' @param AcNum 		An integer scalar > 0, number of equally-spaced, cross-lake, acoustic transects (oriented west-to-east).
#' @param AcInterval	A numeric scalar, length (distance) of acoustic interval (in m).
#' @param AcLayer		A numeric scalar, depth of acoustic layer (in m).
#' @param AcAngle		A numeric scalar, full beam angle width of down-looking acoustic transducer (in degrees).
#' @param MtNum			An integer scalar > 0, target number of midwater trawl tows (oriented west-to-east along acoustic transects at random water depths).
#' @param MtHt			A numeric scalar, height of rectangular midwater trawl opening (in m).
#' @param MtWd			A numeric scalar, width of rectangular midwater trawl opening (in m).
#' @param MtLen			A numeric scalar, length (distance) of midwater trawl haul (in m).
#' @param MtMinCat		An integer scalar, the minimum catch (number of fish) per midwater trawl tow, default 2.  
#' Tows capturing fewer than \code{MtMinCat} fish will be tossed out.
#' @param MtMulti		An integer scalar, the initial number of midwater trawl tows is mulitplied by this scalar
#' in an attempt to achieve the target number of tows, \code{MtNum}, even after eliminating those tows that extend beyond the boundaries of the lake 
#' or those with fewer than \code{MtMinCat}, default 6.
#' @param PlotsPdf		A character scalar, name of pdf file to store the diagnostic plots in.  If NA, the default, 
#' plots are displayed on the screen instead.  If FALSE, no plots are created.
#' @param Seed			An integer scalar, starting seed for stochasticity incorporated in placement of acoustic transects and midwater trawl tows.  
#' Use \code{Seed} to ensure the survey is conducted in the same location with each call to \code{SampFish}.  
#' Otherwise, if set to NULL, the default, a random seed is used, resulting in a different tow location with each call to \code{SampFish}.  
#'
#' @return 				A list with 4 elements.  
#' \itemize{
#'   \item \code{Targets} is a data frame with information on fish detected in the virtual acoustics survey.  Each row represents
#' a single target, columns describe the specific location of fish in the lake, their target strengths, and range weights (see Details).  
#' Three columns are included that would not be available in a real acoustic survey: group (\code{g}) and size (\code{len} and \code{wt}).
#'   \item \code{AcSummaryCell} is a data frame with information on the acoustic survey summarized by acoustic interval and layer.
#'   \item \code{AcSummaryColumn} is a data frame with information on the acoustic survey summarized by acoustic interval.
#'   \item \code{MtCatch} is a data frame with information on the fish captured in the virtual midwater trawl survey.  Each row represents
#' a single fish, columns describe the specific location of the trawl and the group and size of the fish.  Seven columns are included
#' that would not be available in a real midwater trawl survey: the specific location of the fish 
#' (\code{f.east}, \code{f.north}, \code{f.d2sh}, \code{f.botdep}, \code{f.wdep}, \code{f.d2bot}) and their target strenghs (\code{ts}).
#' }
#'
#' @details
#'
#' All sampling is assumed to be "perfect" with no issues of fish availability, acoustic dead zones, or trawl selectivity.
#' So, the acoustic transects capture echoes from all fish that fall within the triangular prism 
#' defined by the randomly selected northing of the transect and the beam angle (\code{AcAngle}) of the transducer, 
#' which is assumed to be at the surface of the water.
#' And, the midwater trawl tows capture all fish that fall within the rectangular prism 
#' defined by the randomly selected water depth of the tow, the trawl gape (\code{MtHt} and \code{MtWd}), and the tow length (\code{MtLen}).
#'
#' A weighting variable, range weight (Yule 2000), is used to account for different volumes of water
#' sampled in the acoustic survey as a function of the distance from the transducer (in m) and the transducer half angle (0.5 * \code{AcAngle}).
#' This value is reported as \code{rng.wt} in the \code{Targets} data frame, and its sum is reported as \code{sum.rw} in the 
#' \code{AcSummaryCell} and \code{AcSummaryColumn} data frames.
#'
#' Three diagnostic plots are produced, if \code{PlotsPdf} is not FALSE.
#' The first is a top (bird's eye) view of the acoustic transects and midwater trawls in lake, drawn to scale.
#' (If you resize the window in R, the scale will not be maintained.)
#' In this plot, acoustic transects are shown as solid blue lines and midwater trawl tows are shown as red rectangles.
#' Second is a side view of each acoustic transect separately, showing the individual fish targets as blue circles 
#' (larger circles indicate larger fish) and midwater trawl tows as red rectangles with the number of fish captured written inside.
#' The acoustic transect number and the number of targets in the transect are printed on the plot.
#' Third is a length frequency histogram for fish captured in each midwater trawl tow.
#' The midwater trawl tow number and the number of fish captured in the tow are printed on the plot.
#'
#' @export
#' @import 				MASS
#' @references 
#' 
#' Yule, DL, JV Adams, DM Warner, TR Hrabik, PM Kocovsky, BC Weidel, LG Rudstam, and PJ Sullivan.  2013.  
#' \href{http://www.nrcresearchpress.com/doi/abs/10.1139/cjfas-2013-0072#.U1KYxPldXTQ}{Evaluating 
#' analytical approaches for estimating pelagic fish biomass using simulated fish communities}. 
#' Canadian Journal of Fisheries and Aquatic Sciences 70:1845-1857.
#' 
#' Yule, DL.  2000.  
#' \href{http://www.tandfonline.com/doi/abs/10.1577/1548-8675(2000)020%3C0759%3ACOHAAP%3E2.3.CO%3B2}{Comparison 
#' of horizontal acoustic and purse-seine estimates of salmonid densities and sizes in eleven Wyoming waters}. 
#' North American Journal of Fisheries Management 20:759-775.
#'
#' @examples
#'
#' # parameters for small (a) and large (A) alewife as input to the simulator
#' fishp <- data.frame(
#' 	G = c("a", "A", "A"), 
#' 	Z = c(50, 140, 140), ZE = c(0.25, 0.2, 0.2), 
#' 	LWC1 = 0.000014, LWC2 = 2.8638, LWCE = 0.18, 
#' 	TSC1 = -64.2, TSC2 = 20.5, TSCE = c(0.02, 0.07, 0.07), 
#' 	PropN = c(0.55, 0.25, 0.20), 
#' 	E = c(NA, 900, 2800), EE = c(NA, 4.5, 0.3), 
#' 	N = NA, NE = NA, 
#' 	WD = c(5, 15, 15), WDE = c(0.5, 0.7, 0.7), 
#' 	D2B = NA, D2BE = NA)
#' 
#' # simulate the fish population
#' res <- SimFish(LakeName="Clear Lake", LkWidth=3000, LkLength=2000, BotDepMin=20, BotDepMax=100, 
#' 	FishParam=fishp, TotNFish=50000)
#'
#' # survey the population
#' surv <- SampFish(SimPop=res, NumEvents=2, AcNum=5, AcInterval=3000, AcLayer=10, AcAngle=7, MtNum=25, MtHt=10, MtWd=10, MtLen=200)
#'
#' # look at the results
#' head(surv$Targets)
#' head(surv$AcSummaryCell)
#' head(surv$AcSummaryColumn)
#' head(surv$MtCatch)
#'

SampFish <- function(SimPop, NumEvents=1, AcNum, AcInterval, AcLayer, AcAngle, MtNum, MtHt, MtWd, MtLen, MtMinCat=2, MtMulti=6, PlotsPdf=NA, Seed=NULL) {

	# SimPop=res
	# NumEvents=2
	# AcNum=3
	# AcInterval=3000
	# AcLayer=10
	# AcAngle=7
	# MtNum=6
	# MtHt=10
	# MtWd=10
	# MtLen=200
	# MtMinCat=2
	# MtMulti=6
	# PlotsPdf=NA
	# Seed=NULL

	if(!is.na(PlotsPdf) & PlotsPdf!=FALSE) pdf(PlotsPdf, width=9, height=6.5, title="Survey", paper="USr")

	# For the purpose of running the code, make sure we have at least two sampling events.
	# If only one event was requested, info from the second event is removed.
	nE.orig <- NumEvents
	NumEvents <- max(nE.orig, 2)

	# easting (m), range, (x direction)
	eastr <- c(0, SimPop$LakeInfo$LkWidth)

	# northing (m), range, (y direction)
	northr <- c(0, SimPop$LakeInfo$LkLength)

	# distance from west and east shore excluded from lake in m (x direction)
	d2shr.we <- c(0+SimPop$LakeInfo$ints[1]/SimPop$LakeInfo$slopes[1], -SimPop$LakeInfo$ints[2]/SimPop$LakeInfo$slopes[2]-eastr[2])



	###  SAMPLING GEAR & PROCESSING  ###

	# increase the number of initial trawls, so we'll still have enough when we get rid of those that 
	# hit bottom and those with fewer than 2 fish
	nT2 <- ceiling(MtMulti*MtNum/AcNum)*AcNum


	ACid <- 1:(AcNum*NumEvents)
	ACspace <- diff(northr)/AcNum

	sampinfo <- as.data.frame(matrix(NA, nrow=nT2*NumEvents, ncol=10, 
		dimnames=list(NULL, c("Event", "ACid", "ACnorth", "MTRgrp", "MTRid", "MTReast", "MTRbdep", "MTRwdep", "MTRd2sh", "MTRd2bot"))))
	sampinfo$Event <- rep(1:NumEvents, rep(nT2, NumEvents))
	sampinfo$ACid <- rep(1:(AcNum*NumEvents), rep(nT2/AcNum, AcNum*NumEvents))
	sampinfo$MTRgrp <- rep(1:(nT2/AcNum), AcNum*NumEvents)
	sampinfo$MTRid <- seq(along=sampinfo$MTRgrp)

	if(!is.null(Seed)) set.seed(Seed)

	for(k in 1:NumEvents) {
		sel <- sampinfo$Event==k
		ACstart <- runif(1, northr[1], northr[2])
		ACnorth <- sort(unique(c(seq(ACstart, northr[1], -ACspace), seq(ACstart, northr[2], ACspace))))
		sampinfo$ACnorth[sel] <- rep(ACnorth, rep(nT2/AcNum, AcNum))
		sampinfo$MTReast[sel] <- runif(nT2, eastr[1]+MtLen/2, eastr[2]-MtLen/2)

		# calculate midwater trawl measures for the MIDPOINT of the trawl
		sampinfo$MTRbdep[sel] <- zfromx(x=sampinfo$MTReast[sel], maxz=SimPop$LakeInfo$BotDepMax, eastr=eastr, 
			ints=SimPop$LakeInfo$ints, slopes=SimPop$LakeInfo$slopes)

		# random selection of midwater trawl depth
		sampinfo$MTRwdep[sel] <- runif(nT2, 0+(MtHt/2), sampinfo$MTRbdep[sel]-(MtHt/2))

		sampinfo$MTRd2sh[sel] <- dfromx(x=sampinfo$MTReast[sel], d2shr.we=d2shr.we, eastr=eastr)
		sampinfo$MTRd2bot[sel] <- sampinfo$MTRbdep[sel] - sampinfo$MTRwdep[sel]

		# make sure acoustic transect cones don't overlap
		mindist.allowed <- SimPop$LakeInfo$BotDepMax*tan(pi*AcAngle/2/360)
		mindist.observed <- min(diff(sort(ACnorth)))
		if(mindist.observed < mindist.allowed) warning("Acoustic transects are too close together.\nTry again with fewer acoustic transects.")
		}

	# make sure that all of the acoustic transects are kept ... even if they have no midwater trawls associated with them
	ACsampinfo <- sampinfo[first(sampinfo$ACid)==1, 1:3]

	# make sure that midwater trawl doesn't hit bottom
	MTRbdep1 <- zfromx(x=sampinfo$MTReast - (MtLen/2), maxz=SimPop$LakeInfo$BotDepMax, eastr=eastr, ints=SimPop$LakeInfo$ints, slopes=SimPop$LakeInfo$slopes)
	MTRbdep2 <- zfromx(x=sampinfo$MTReast + (MtLen/2), maxz=SimPop$LakeInfo$BotDepMax, eastr=eastr, ints=SimPop$LakeInfo$ints, slopes=SimPop$LakeInfo$slopes)
	hits.bottom <- (MTRbdep1 - (sampinfo$MTRwdep + MtHt/2)) < 0 | (MTRbdep2 - (sampinfo$MTRwdep + MtHt/2)) < 0

	# make sure that midwater trawl doesn't extend too far east/west/north/south
	extends.out <- sampinfo$ACnorth - MtWd/2 < northr[1] |
		sampinfo$ACnorth + MtWd/2 > northr[2] |
		sampinfo$MTReast - MtLen/2 < eastr[1] |
		sampinfo$MTReast + MtLen/2 > eastr[2]

	sampinfo <- sampinfo[!hits.bottom & !extends.out, ]

	rm(ACid, ACspace, sel, ACstart, ACnorth, mindist.allowed, mindist.observed, MTRbdep1, MTRbdep2, hits.bottom, extends.out)



	# acoustic transects

	attach(ACsampinfo)

	# convert half of the down-looking angle from degrees to radians
	half.cone.rad <- 2*pi*(AcAngle/2)/360

	# select only those targets within the volume of space sampled by the acoustic transect (triangular prism)
	sua <- sort(unique(ACid))
	AC <- data.frame(matrix(NA, nrow=0, ncol=13, dimnames=list(NULL, c("Event", "ACid", "ACnorth", 
		"g", "f.east", "f.north", "f.d2sh", "f.botdep", "f.wdep", "f.d2bot", "len", "wt", "ts"))))
	# acoustic slice cone cushion, based on angle of transducer and maximum depth
	cushion <- SimPop$LakeInfo$BotDepMax*tan(half.cone.rad)

	# create a single row of missing values that looks just like the "fish" data frame
	# this will be used to maintain a row of information on an acoustic transect, even if it captures no targets
	nofish <- SimPop$Fish[1, ]
	ncol <- dim(SimPop$Fish)[2]
	nofish[1, 1:ncol] <- rep(NA, ncol)
	rm(ncol)

	# acoustic transects
	for(j in sua) {
		# make sure that the acoustic slice does not extend further north or south than our sample space
		if(ACnorth[j] > (northr[2] - cushion) | ACnorth[j] < (northr[1] + cushion)) 
			warning(paste("\nACid = ", ACid[j], ", ACnorth = ", ACnorth[j], 
				": \nThe cone of the acoustic slice extends farther north or south \nthan the boundary of our simulated lake.",
				"  \nTry again using a different Seed or using fewer acoustic transects."))
		sel <- (abs(SimPop$Fish$f.north - ACnorth[j])) < (SimPop$Fish$f.wdep*tan(half.cone.rad))

		if(sum(sel)>0) {
			temp <- data.frame(ACsampinfo[rep(j, sum(sel)), c("Event", "ACid", "ACnorth")], SimPop$Fish[sel, ])
			AC <- rbind(AC, temp)
			} else {
			temp <- data.frame(ACsampinfo[rep(j, 1), c("Event", "ACid", "ACnorth")], nofish)
			AC <- rbind(AC, temp)
			}
		}

	rm(cushion)

	detach(ACsampinfo)
	attach(sampinfo)



	# midwater trawl tows
	# select only those targets within the volume of space sampled by the midwater trawl (rectangular prism)
	sut <- sort(unique(MTRid))
	MTRbig <- data.frame(matrix(NA, nrow=0, ncol=20, dimnames=list(NULL, 
		c("Event", "ACid", "ACnorth", "MTRgrp", "MTRid", "MTReast", "MTRbdep", "MTRwdep", "MTRd2sh", "MTRd2bot", 
		"g", "f.east", "f.north", "f.d2sh", "f.botdep", "f.wdep", "f.d2bot", "len", "wt", "ts"))))
	for(m in sut) {
		j <- match(m, MTRid)
		sel <- SimPop$Fish$f.north >= (ACnorth[j] - MtWd/2) & SimPop$Fish$f.north <= (ACnorth[j] + MtWd/2) &
			SimPop$Fish$f.east >= (MTReast[j] - MtLen/2) & SimPop$Fish$f.east <= (MTReast[j] + MtLen/2) &
			SimPop$Fish$f.wdep <= (MTRwdep[j] + MtHt/2) & SimPop$Fish$f.wdep >= (MTRwdep[j] - MtHt/2)
		if(sum(sel) >= MtMinCat) {
			temp <- cbind(sampinfo[rep(j, sum(sel)), ], SimPop$Fish[sel, ])
			MTRbig <- rbind(MTRbig, temp)
			}
		}

	if(dim(MTRbig)[1] > 0) {

		### select only needed number of trawls (remember, we sampled many more than what we needed!) ##

		# create an index of trawls
		mtr.indx <- MTRbig[first(MTRbig$MTRid)==1, c("Event", "ACid", "MTRgrp", "MTRid")]
		mtr.indx$mtr.grp <- unlist(lapply(table(mtr.indx$ACid), sample))
		# create a random variable for sorting
		y <- runif(length(mtr.indx$mtr.grp))
		# sort the index of trawls by event abd group number
		mtr.indx.sort <- mtr.indx[order(mtr.indx$Event, mtr.indx$mtr.grp, y), ]

		# count up the number of trawls in each event
		f <- first(mtr.indx.sort$Event)
		x <- rep(NA, length(f))
		for(ix in 1:length(f)) {
			x[ix] <- if(f[ix]==1) 1 else x[ix-1]+1
			}
		mtr.indx.sort$mtr.count <- x
		# keep the first MtNum trawls in each event
		mtr.indx.keep <- mtr.indx.sort[mtr.indx.sort$mtr.count <= MtNum, ]

		MTR <- MTRbig[MTRbig$MTRid %in% mtr.indx.keep$MTRid, ]
		sampinfo.sub <- sampinfo[sampinfo$MTRid %in% mtr.indx.keep$MTRid, ]

		rm(mtr.indx, y, mtr.indx.sort, f, x, mtr.indx.keep)

		} else {
		MTR <- MTRbig[0, ]
		sampinfo.sub <- sampinfo[0, ]
		}

	old.n <- c("ACnorth")
	new.n <- c("ACMTRnorth")
	names(MTR)[match(old.n, names(MTR))] <- new.n

	detach(sampinfo)



	# categorize targets interval (along transect) and layer (in water column), both in m
	int. <- cut(AC$f.east, include.lowest=TRUE, breaks=seq(eastr[1], eastr[2]+AcInterval-1, AcInterval))
	AC$interval <- as.numeric(int.)
	AC$east <- sapply(strsplit(gsub("\\(|\\)|\\[|\\]", "", as.character(int.)), ","), function(x) mean(as.numeric(x)))
	lay. <- cut(AC$f.wdep, include.lowest=TRUE, breaks=seq(0, SimPop$LakeInfo$BotDepMax+AcLayer-1, AcLayer))
	AC$layer <- as.numeric(lay.)
	AC$wdep <- sapply(strsplit(gsub("\\(|\\)|\\[|\\]", "", as.character(lay.)), ","), function(x) mean(as.numeric(x)))
	rm(int., lay.)

	# create a matrix of all possible interval-by-layer combinations for each ACid
	# this will be used to ensure that interval-by-layers with no fish are included in later summaries

	# each AC transect is the same length, so each will have all of the possible intervals
	all.ints <- seq(from=length(seq(eastr[1], eastr[2]+AcInterval-1, AcInterval))-1)

	# each AC transect goes over the same depth profile, so we can determine the max depth for each interval
	# then see whether the max layer included

	easts <- seq(eastr[1], eastr[2], length=1000)
	depth.contour <- zfromx(x=easts, maxz=SimPop$LakeInfo$BotDepMax, eastr=eastr, ints=SimPop$LakeInfo$ints, slopes=SimPop$LakeInfo$slopes)
	depth.cont.int <- as.numeric(cut(easts, include.lowest=TRUE, breaks=seq(eastr[1], eastr[2]+AcInterval-1, AcInterval)))
	all.maxes <- tapply(depth.contour, depth.cont.int, max)

	max.lays <- as.numeric(cut(all.maxes, include.lowest=TRUE, breaks=seq(0, SimPop$LakeInfo$BotDepMax+AcLayer-1, AcLayer)))

	# full matrix of all ACids, all intervals, and all layers
	full.mat <- expand.grid(layer=1:max(max.lays), interval=all.ints, ACid=ACsampinfo$ACid)
	full.mat <- merge(full.mat, ACsampinfo[, c("ACid", "Event")])

	sub.mat <- merge(data.frame(interval=all.ints, max.layer=max.lays), full.mat, all=TRUE)
	sub.mat <- sub.mat[sub.mat$layer <= (sub.mat$max.layer + 0.5), c("Event", "ACid", "interval", "layer")]

	rm(all.ints, easts, depth.contour, depth.cont.int, all.maxes, max.lays, full.mat)

	# add "range weight" to the AC data (Yule 2000)
	# a weighting variable to account for different volumes sampled as a function of range (dist. from ducer in m) and ducer half angle
	AC$rng.wt <- 1/(2*AC$f.wdep*tan(half.cone.rad))

	# summarize acoustic data by interval and layer
	AC$indx <- paste(AC$ACid, AC$interval, AC$layer, sep="-")
	sum.rw <- tapply(AC$rng.wt, AC$indx, sum)
	ord <- match(names(sum.rw), AC$indx)
	ACsmryIL <- AC[ord, c("Event", "ACid", "interval", "layer", "ACnorth", "east", "wdep")]
	ACsmryIL$sum.rw <- sum.rw
	rm(sum.rw, ord)
	ACsmryIL <- ACsmryIL[order(ACsmryIL$ACid, ACsmryIL$interval, ACsmryIL$layer), ]

	old.n <- c("ACnorth")
	new.n <- c("north")
	names(ACsmryIL)[match(old.n, names(ACsmryIL))] <- new.n
	ACsmryIL$nperha <- 10000 * ACsmryIL$sum.rw/AcInterval
	rm(old.n, new.n)

	ACsmryIL$botdep <- zfromx(x=ACsmryIL$east, maxz=SimPop$LakeInfo$BotDepMax, eastr=eastr, ints=SimPop$LakeInfo$ints, slopes=SimPop$LakeInfo$slopes)
	ACsmryIL$d2bot <- ACsmryIL$botdep - ACsmryIL$wdep
	ACsmryIL$d2sh <- dfromx(x=ACsmryIL$east, d2shr.we=d2shr.we, eastr=eastr)

	ACsmryIL <- merge(ACsmryIL, sub.mat, all=TRUE)
	ACsmryIL$nperha[is.na(ACsmryIL$nperha)] <- 0

	# summarize acoustic data by interval only
	ACsmryI <- aggregate(ACsmryIL[, c("sum.rw", "nperha")], 
		ACsmryIL[, c("Event", "ACid", "interval", "north", "east", "botdep", "d2sh")], sum)
	ACsmryI <- ACsmryI[order(ACsmryI$Event, ACsmryI$ACid, ACsmryI$interval), ]



	###  diagnostic plots  ###
	if(is.na(PlotsPdf) | PlotsPdf!=FALSE) {

		attach(sampinfo.sub)

		sel <- AC$Event==1
		ts.scaled <- (AC$ts[sel] - SimPop$FishInfo$TSRange[1])/diff(SimPop$FishInfo$TSRange)
		sua <- sort(unique(AC$ACid[sel]))
		sut <- sort(unique(MTRid[Event==1]))


		# top view of acoustic transects and midwater trawls - to scale
		if(is.na(PlotsPdf)) windows(w=9, h=6.5)
		par(mfrow=c(1, 1), oma=rep(0, 4), mar=c(5.1, 4.1, 4.1, 2.1))
		eqscplot(1, 1, type="n", xlim=eastr/1000, ylim=northr/1000, axes=FALSE, xlab="Easting  (km)", ylab="Northing  (km)", 
			main=paste(SimPop$LakeInfo$LakeName, "- Top View - drawn to scale"))
		axis(1)
		axis(2, las=1)
		arrows(rep(eastr[1], length(sua))/1000, AC$ACnorth[match(sua, AC$ACid[sel])]/1000, 
			rep(eastr[2], length(sua))/1000, AC$ACnorth[match(sua, AC$ACid[sel])]/1000, length=0, lwd=2, col="blue") 
		polygon(eastr[c(1, 2, 2, 1)]/1000, northr[c(1, 1, 2, 2)]/1000)
		if(length(sut)>0) {
			for(m in seq(along=sut)) {
				sel2 <- MTRid==sut[m]
				polygon((MTReast[sel2]+c(-1, 1, 1, -1)*MtLen/2)/1000, (ACnorth[sel2]+c(1, 1, -1, -1)*MtWd/2)/1000, border="red", lwd=3)
				}
			rm(sel2)
			}


		# plot of each acoustic transect with outline of midwater trawl tows
		if(is.na(PlotsPdf)) windows(w=9, h=6.5)
		par(mfrow=n2mfrow(length(sua)), oma=c(2, 2, 2, 0), mar=c(3, 3, 1, 1))
		catch.tots <- table(MTR$MTRid)
		for(j in seq(along=sua)) {
			plot(AC$f.east/1000, -AC$f.wdep, type="n", las=1, xlab="", ylab="")
			sel3 <- AC$ACid==sua[j]
			points(AC$f.east[sel3]/1000, -AC$f.wdep[sel3], cex=2*ts.scaled, col="blue")
			points(AC$f.east[sel3]/1000, -AC$f.botdep[sel3], pch=16, cex=0.5)
			sut2 <- sort(unique(MTRid[ACid==sua[j]]))
			mtext(paste("id=", sua[j], "\nn=", sum(sel3), sep=""), side=1, line=-1.5, adj=0.98, font=2, cex=par("cex"))
			if(length(sut2)>0) {
				for(m in seq(along=sut2)) {
					sel2 <- MTRid==sut2[m]
					polygon((MTReast[sel2]+c(-1, 1, 1, -1)*MtLen/2)/1000, -MTRwdep[sel2]+c(1, 1, -1, -1)*MtHt/2, border="red", col="white")
					text(MTReast[sel2]/1000, -MTRwdep[sel2], catch.tots[sel2], font=2, col="red")
					}
				rm(sel2)
				}
			}
		mtext("Easting  (km)", side=1, outer=TRUE)
		mtext("Fishing depth  (m)", side=2, outer=TRUE)
		mtext(paste(SimPop$LakeInfo$LakeName, "- Acoustic Transects and Midwater Trawls"), side=3, outer=TRUE, font=2)


		# plot of each midwater trawl catch
		if(length(sut)>0) {
			barz <- tapply(!is.na(MTR$len), list(MTR$g, 50*floor(MTR$len/50), MTR$MTRid), sum)
			barz[is.na(barz)] <- 0
			barz <- barz[, , dimnames(barz)[[3]] %in% sut, drop=FALSE]
			barz <- barz[apply(barz, 1, sum)>0, , , drop=FALSE]
			sus <- dimnames(barz)[[1]]
			if(is.na(PlotsPdf)) windows(w=9, h=6.5)
			par(mfrow=n2mfrow(length(sut)), oma=c(2, 2, 2, 0), mar=c(3, 3, 1, 1))
			for(m in seq(along=sut)) {
				barplot(barz[, , m], ylim=c(0, max(apply(barz, 2:3, sum))), col=1:50, 
					names.arg=paste(dimnames(barz)[[2]], "+", sep=""), las=1)
				mtext(paste("id=", sut[m], "\nn=", sum(barz[, , m]), sep=""), side=3, line=-2.5, adj=0.98, font=2, cex=par("cex"))
				box()
				}
			mtext("Length  (mm)", side=1, outer=TRUE)
			mtext("Frequency", side=2, outer=TRUE)
			mtext(paste(SimPop$LakeInfo$LakeName, "- Midwater Trawl Catch"), side=3, outer=TRUE, font=2)
			legend("topleft", sus, fill=seq(sus))
			rm(barz, sus)
			}


		detach(sampinfo.sub)

		if(!is.na(PlotsPdf)) graphics.off()

		}



	cat(paste0("Mean number of fish per acoustic transect = ", signif(mean(table(AC$ACid)), 2), "\n"))
	cat(paste0("Mean number of fish per midwater trawl tow = ", signif(mean(table(MTR$MTRid)), 2), "\n"))

	ac.out.vars <- c("Event", "ACid", "interval", "layer", "f.east", "f.north", "f.d2sh", "f.botdep", "f.wdep", "f.d2bot", "ts", "rng.wt", "g", "len", "wt")
	# setdiff(names(AC), ac.out.vars)
	# 3 variables unknown to targets: "g" "len" "wt"

	acsumil.out.vars <- c("Event", "ACid", "interval", "layer", "east", "north", "d2sh", "botdep", "wdep", "d2bot", "sum.rw", "nperha")
	# setdiff(names(ACsmryIL), acsumil.out.vars)

	acsumi.out.vars <- c("Event", "ACid", "interval", "east", "north", "d2sh", "botdep", "sum.rw", "nperha")
	# setdiff(names(ACsmryI), acsumi.out.vars)

	mtr.out.vars <- c("Event", "ACid", "MTRid", "MTReast", "ACMTRnorth", "MTRd2sh", "MTRbdep", "MTRwdep", "MTRd2bot", "g", "len", "wt",
		"f.east", "f.north", "f.d2sh", "f.botdep", "f.wdep", "f.d2bot", "ts")
	# setdiff(names(MTR), mtr.out.vars)
	# 7 variables unknown to trawl catch: "f.east"   "f.north"  "f.d2sh"   "f.botdep" "f.wdep"   "f.d2bot"  "ts"

	#### only save *1* sampling event, if that is what was originally specified ###
	if(nE.orig==1) {
		AC <- AC[AC$Event==1, ac.out.vars]
		ACsmryIL <- ACsmryIL[ACsmryIL$Event==1, acsumil.out.vars]
		ACsmryI <- ACsmryI[ACsmryI$Event==1, acsumi.out.vars]
		MTR <- MTR[MTR$Event==1, mtr.out.vars]
		} else {
		AC <- AC[, ac.out.vars]
		ACsmryIL <- ACsmryIL[, acsumil.out.vars]
		ACsmryI <- ACsmryI[, acsumi.out.vars]
		MTR <- MTR[, mtr.out.vars]
		}

	list(Targets=AC, AcSummaryCell=ACsmryIL, AcSummaryColumn=ACsmryI, MtCatch=MTR)
	}