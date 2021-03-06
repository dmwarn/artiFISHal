% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SampFish.R
\name{SampFish}
\alias{SampFish}
\title{Survey a Fish Population}
\usage{
SampFish(SimPop, NumEvents = 1, AcNum, AcInterval, AcLayer, AcAngle, MtNum,
  MtHt, MtWd, MtLen, MtMinCat = 2, MtMulti = 6, PlotsPdf = FALSE,
  Seed = NULL)
}
\arguments{
\item{SimPop}{A list with elements \code{LakeInfo}, \code{FishInfo}, \code{FishParam},
\code{FishPop}, typically output from \code{\link{SimFish}}.}

\item{NumEvents}{An integer scalar, number of sampling events, i.e., number of times
to repeat the survey.}

\item{AcNum}{An integer scalar > 0, number of equally-spaced, cross-lake,
acoustic transects (oriented west-to-east).}

\item{AcInterval}{A numeric scalar, length (distance) of acoustic interval (in m).}

\item{AcLayer}{A numeric scalar, depth of acoustic layer (in m).}

\item{AcAngle}{A numeric scalar, full beam angle width of down-looking acoustic transducer
(in degrees).}

\item{MtNum}{An integer scalar > 0, target number of midwater trawl tows
(oriented west-to-east along acoustic transects at random water depths).}

\item{MtHt}{A numeric scalar, height of rectangular midwater trawl opening (in m).}

\item{MtWd}{A numeric scalar, width of rectangular midwater trawl opening (in m).}

\item{MtLen}{A numeric scalar, length (distance) of midwater trawl haul (in m).}

\item{MtMinCat}{An integer scalar, the minimum catch (number of fish) per
midwater trawl tow, default 2.
Tows capturing fewer than \code{MtMinCat} fish will be tossed out.}

\item{MtMulti}{An integer scalar, the initial number of midwater trawl tows is multiplied
by this scalar in an attempt to achieve the target number of tows,
\code{MtNum}, even after eliminating those tows that extend beyond
the boundaries of the lake or those with fewer than \code{MtMinCat},
default 6.}

\item{PlotsPdf}{A character scalar, name of pdf file to store the diagnostic plots in.
If FALSE, the default, no plots are created.}

\item{Seed}{An integer scalar, starting seed for stochasticity incorporated in
placement of acoustic transects and midwater trawl tows.
Use \code{Seed} to ensure the survey is conducted in the same location
with each call to \code{SampFish}.
Otherwise, if set to NULL, the default, a random seed is used,
resulting in a different tow location with each call to \code{SampFish}.}
}
\value{
A list with 3 elements.
  \itemize{
    \item \code{SurvParam} is a named vector with the survey inputs supplied
      as arguments to \code{SampFish}.
    \item \code{Targets} is a data frame with information on fish detected
      in the virtual acoustics survey.  Each row represents a single target,
      columns describe the specific location of fish in the lake and
      their target strengths.
      Three columns are included that would not be available in a real
      acoustic survey: group (\code{G}) and size (\code{len} and \code{wt}).
    \item \code{MtCatch} is a data frame with information on the fish
      captured in the virtual midwater trawl survey.  Each row represents
      a single fish, columns describe the specific location of the trawl and
      the group and size of the fish.  Seven columns are included
      that would not be available in a real midwater trawl survey:
      the specific location of the fish (\code{f.east}, \code{f.north},
      \code{f.d2sh}, \code{f.botdep}, \code{f.wdep}, \code{f.d2bot}) and
      their target strengths (\code{ts}).
  }
}
\description{
Sample a simulated population of pelagic fish
(created with \code{\link{SimFish}}) with down-looking acoustics
(cross-lake, west-to-east) and midwater trawls (west-to-east).
}
\details{
All sampling is assumed to be "perfect" with no issues of fish
  availability, acoustic dead zones, or trawl selectivity.
  So, the acoustic transects capture echoes from all fish that fall within
  the triangular prism defined by the randomly selected northing of
  the transect and the beam angle (\code{AcAngle}) of the transducer,
  which is assumed to be at the surface of the water.
  And, the midwater trawl tows capture all fish that fall within
  the rectangular prism defined by the randomly selected water depth of
  the tow, the trawl gape (\code{MtHt} and \code{MtWd}), and
  the tow length (\code{MtLen}).

  Three diagnostic plots are produced, if \code{PlotsPdf} is not FALSE.
  The first is a top (bird's eye) view of the acoustic transects and midwater
  trawls in lake, drawn to scale.
  In this plot, acoustic transects are shown as solid blue lines and
  midwater trawl tows are shown as red rectangles.
  Second is a side view of each acoustic transect separately, showing
  the individual fish targets as blue circles
  (larger circles indicate larger fish) and midwater trawl tows as
  red rectangles with the number of fish captured written inside.
  The acoustic transect number and the number of targets in the transect are
  printed on the plot.
  Third is a length frequency histogram for fish captured in each midwater
  trawl tow. The midwater trawl tow number and the number of fish captured in
  the tow are printed on the plot.
}
\examples{
# parameters for small (a) and large (A) alewife as input to the simulator
fishp <- data.frame(
  G = c("a", "A", "A"),
  Z = c(50, 140, 140), ZE = c(0.25, 0.2, 0.2),
  LWC1 = 0.000014, LWC2 = 2.8638, LWCE = 0.18,
  TSC1 = -64.2, TSC2 = 20.5, TSCE = c(0.02, 0.07, 0.07),
  PropN = c(0.55, 0.25, 0.20),
  E = c(NA, 900, 2800), EE = c(NA, 4.5, 0.3),
  N = NA, NE = NA,
  WD = c(5, 15, 15), WDE = c(0.5, 0.7, 0.7),
  D2B = NA, D2BE = NA
)

# simulate the fish population
res <- SimFish(LakeName="Clear Lake", LkWidth=3000, LkLength=2000,
 BotDepMin=20, BotDepMax=100, FishParam=fishp, TotNFish=50000, Seed=667)

# survey the population
surv <- SampFish(SimPop=res, NumEvents=2, AcNum=5, AcInterval=3000,
 AcLayer=10, AcAngle=7, MtNum=25, MtHt=10, MtWd=10, MtLen=200, Seed=545)

# look at the results
surv$SurvParam
head(surv$Targets)
head(surv$MtCatch)
}
\references{
Yule, DL, JV Adams, DM Warner, TR Hrabik, PM Kocovsky, BC Weidel,
    LG Rudstam, and PJ Sullivan.  2013.
  Evaluating analytical approaches for estimating pelagic fish biomass using
    simulated fish communities.
  Canadian Journal of Fisheries and Aquatic Sciences 70:1845-1857.
  \emph{http://www.nrcresearchpress.com/doi/abs/10.1139/cjfas-2013-0072#.U1KYxPldXTQ}

  Yule, DL.  2000.  Comparison of horizontal acoustic and purse-seine
    estimates of salmonid densities and sizes in eleven Wyoming waters
  North American Journal of Fisheries Management 20:759-775.
  \emph{http://www.tandfonline.com/doi/abs/10.1577/1548-8675(2000)020\%3C0759\%3ACOHAAP\%3E2.3.CO\%3B2}
}
\seealso{
\code{\link{SimFish}}
}

