\name{yeast}
\encoding{UTF-8}
\alias{yeast}

\docType{data}

\title{Yeast metabolomic study}

\description{
Two Saccharomyces Cerevisiae strains were compared under two different environmental conditions, 37 metabolites expression are measured. 
} 

\usage{data(yeast)}

\format{
A list containing the following components:
  \describe{
    \item{\code{data}}{data matrix with 55 rows and 37 columns. Each row represents 
      an experimental sample, and each column a single metabolite.}
	\item{\code{strain}}{a factor containing the type of strain (MT or WT).}
	\item{\code{condition}}{a factor containing the type of environmental condition (AER or ANA).}
	\item{\code{strain.condition}}{a crossed factor between \code{strain} and \code{condition}.}
  }
}

\details{
In this study, two Saccharomyces cerevisiae strains were used - wild-type (WT)
and mutant (MT), and were carried out in batch cultures under two different environmental conditions,
aerobic (AER) and anaerobic (ANA) in standard mineral media with glucose as the sole carbon source.
After normalization and pre processing, the metabolomic data results in 37 metabolites and 55 samples
which include 13 MT-AER, 14 MT-ANA, 15 WT-AER and 13 WT-ANA samples
}


\references{
Villas-Boas S, Moxley J, Akesson M, Stephanopoulos G, Nielsen J: High-throughput metabolic state analysis (2005). The missing link in integrated functional genomics. \emph{Biochemical Journal}, bold{388}:669–677.
}

\keyword{datasets}
