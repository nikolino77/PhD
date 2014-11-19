%%
%% dukedissertation -- a document class for dissertations and theses
%% conforming to the 2007 Duke University guidelines.  This class is by
%% Michael Gratton.  It is based on the 2004 LaTeX 2e version of 
%% report.cls and code in the older dukethesis.sty.
%%
%% report.cls is Copyright 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 
%% 2003 2004 The LaTeX3 Project.
%%
%% dukethesis.cls contained work by Mark Holliday, Charlie Martin, Russ Tuck,
%% Sean O'Connell, Michael Todd, Syam Gadde, and Rajiv Wickremesinghe.
%% 
%% 
%% This file may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, either version 1.3
%% of this license or (at your option) any later version.
%% The latest version of this license is in
%%    http://www.latex-project.org/lppl.txt
%% and version 1.3 or later is part of all distributions of LaTeX
%% version 2003/12/01 or later.
%% 
%% =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
%%
%% Version 0.40
%% October 27, 2008  - Michael Gratton (mgratton@math.duke.edu)
%% 
%% This class conforms to the 2007 style guidelines for dissertations,
%% including:
%% 1) Page numbers centered in the footer of each page
%% 2) Margins: 1in top, 1in right, 1.5in left, 1in below footer
%% 3) Title signature page, UMI abstract title signature page, and copyright 
%%    page automatically generated at \maketitle
%% 4) 'Double' spacing throughout body text (really about 10pt extra instead
%%    of 12pt extra, but it passes)
%% 5) Single spacing in the Table of Contents, List of Tables, List of 
%%    Figures, Bibliography, and in chapter, section titles, and figure/table 
%%    captions.
%% 6) Footnotes are numbered consecutively within a chapter and placed at the
%%    bottom of the page on which the reference number appears.
%% 7) Page ordering and numbering: roman numeral page numbers appear
%%    in the frontmatter (prior to the introduction or Chapter 1).  The first 
%%    numbered page is the Abstract (usuall iv).  Arabic numbering from '1'
%%    starts in the Introduction or Chapter 1 if there's no Introduction.
%% 8) Optional material supported: 
%%    *Dedication
%%    *Acknowledgements
%%    *Introduction (different from 'Chapter 1: Introduction')
%%    *Appendicies
%%
%% This class also provides some handy features:
%% 1) Use the option 'economy' to get a single-spaced document appropriate for
%%    giving to colleagues.
%% 2) Change your copyright from 'All rights reserved' if you're not actaully
%%    reserving all your rights.
%% 3) NEW LOOK: Boldface mostly removed in headers for a lighter feel.  
%%    The word 'Chapter' no longer appears on opener pages, only the number.
%% 4) OLD LOOK: there's now an option 'oldstyle' to get the standard LaTeX
%%    report.cls look back
%%
%% Limitations:
%% In it's current form, this class does not support committees larger than
%% six members or titles longer than four lines.  The 
%% figure-to-caption space has been abbreviated, as most plotting programs 
%% provide ample bottom margins.  
%% 





\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{dukedissertation}
              [2007/04/16 Version 0.3]
\RequirePackage{graphicx}
\RequirePackage{ifthen}

% Test if pdflatex is being used
%\newif\ifpdf\ifx\pdfoutput\undefined\pdffalse\else\pdfoutput=1\pdftrue\fi

% Internal logic (replicates some book.cls features)
\newif\if@frontmatter
\@frontmattertrue
\newif\if@inappendix
\@inappendixfalse

% Option switches and their default values
\newif\if@Gradschool  % Produce extra frontmatter for grad school
\newif\if@MS  % Masters thesis format
\newlength\@SimSpace  % double-space
\newlength\@OpenupSpace
\newboolean{oldstyle} 
\newboolean{centerpage}


\DeclareOption{economy}{%  Set a bunch of options at once
  \ExecuteOptions{singlespace,nogradschool,nobind}
}
\DeclareOption{gradschool}{\@Gradschooltrue}
\DeclareOption{nogradschool}{\@Gradschoolfalse}
\DeclareOption{MS}{\@MSfalse}
\DeclareOption{PhD}{\@MStrue}
\DeclareOption{oldstyle}{\setboolean{oldstyle}{true}}
\DeclareOption{newstyle}{\setboolean{oldstyle}{false}}
\DeclareOption{nobind}{\setboolean{centerpage}{true}}
\DeclareOption{bind}{\setboolean{centerpage}{false}}
\DeclareOption{doublespace}{%
	\setlength\@SimSpace{10pt} % Simulated double-space skip
	\setlength\@OpenupSpace{3\jot}
}
\DeclareOption{singlespace}{%
	\setlength\@SimSpace{\z@}  % Zero simulated double-space
	\setlength\@OpenupSpace{\z@}
}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ExecuteOptions{gradschool,PhD,doublespace,newstyle,bind}
\ProcessOptions\relax
\LoadClass[11pt,letterpaper]{book}

% Float parameters.  Allow more float per page, open up spacing
\renewcommand{\topfraction}{.75}
\renewcommand{\bottomfraction}{.75}
\renewcommand{\textfraction}{.15}  % About 3 lines of double-spaced text
\renewcommand{\floatpagefraction}{.8}
\renewcommand{\dbltopfraction}{.97}
\renewcommand{\dblfloatpagefraction}{.9}
\setlength{\floatsep}{12pt plus 6pt minus 4pt}
\setlength{\textfloatsep}{15pt plus 8pt minus 5pt}
\setlength{\intextsep}{12pt plus 6pt minus 4pt}
\setlength{\dblfloatsep}{12pt plus 6pt minus 4pt}
\setlength{\dbltextfloatsep}{15pt plus 8pt minus 5pt}
% Float pages have floats near the top of the page
\setlength{\@fptop}{12pt minus 6pt}% removed ``plus 1fil''
\setlength{\@fpsep}{24pt plus 12pt minus 12pt}% removed ``plus 2fil''
\setlength{\@fpbot}{0pt plus 1fil}
\setlength{\@dblfptop}{0pt}% removed ``plus 1fil''
\setlength{\@dblfpsep}{24pt plus 12pt minus 12pt}% removed ``plus 2fil''
\setlength{\@dblfpbot}{0pt plus 1fil}


%-----------------------------------------------------------
%       DOUBLE    S P A C I N G:
% Most of the bother in the thesis format is in the disgusting double
% spacing requirements.  We handle it by a bit of plain TeX.  The 
% \openup command increases the space between baselines unscaled by font
% size.  Double-spacing is
% turned off by the macro \normalbaselines in figure captions, the toc,
% lof, lot, and bibliography.  In the later four, we FAKE double-spacing,
% typically with a \@SimSpace vertical space between entries.
% -----------------------------------------------------------
\newcommand{\@textspace}{\openup \@OpenupSpace\relax}


%-----------------------------------------------------------------------
% Names of environments
%-----------------------------------------------------------------------
\newcommand\biographyname{Biography}
\newcommand\dedicationname{Dedication}
\newcommand\frontname{Front}
\newcommand\ackname{Acknowledgements}
\newcommand\abstractname{Abstract}
\newcommand\loaname{List of Abbreviations and Symbols}

%-----------------------------------------------------------------------
%% Page size specifications
%-----------------------------------------------------------------------
%% Goal: 1.5in on binding edge.  Default 72pt margin plus 36pt
\ifthenelse{\boolean{centerpage}}{%
\setlength{\oddsidemargin}{0.25in}
\setlength{\evensidemargin}{0.25in}
}
{
\setlength{\oddsidemargin}{0.5in} 
\if@twoside
	\setlength{\evensidemargin}{0in}
\else
	\setlength{\evensidemargin}{\oddsidemargin}
\fi
}
%% Deal with known screwiness in the top text placement.
\setlength{\topmargin}{ -24pt}
%% A page consists of 72pt top margin + 0pt header + X body height
%%                  + 25pt foot (with pg number) + 72pt bottom margin
%%                = 792pt = 11in
\setlength{\headheight}{0pt}
\setlength{\textheight}{ 623pt}
\setlength{\footskip}{ 25pt}
\setlength{\textwidth}{ 430pt}

%----------------------------------------------------------------------
% Variables for titlepages
%----------------------------------------------------------------------
\newcommand{\department}[1]{\gdef\@department{#1}}
%\newcommand{\subject}[1]{\gdef\@subject{#1}}
\newcommand{\supervisor}[1]{\gdef\@supervisor{#1}}
\newcommand{\copyrighttext}[1]{\gdef\@copyrighttext{#1}}
% Set default values
\department{??DEPARTMENT??}
%\subject{\@department}  
\supervisor{??ADVISOR??}
\date{\number\year}
\copyrighttext{All rights reserved}
% Count the number of members, include supervisor
\newcounter{@members}           % Number of member macros defined so far.
\newcommand{\@membera}{\@member{\@supervisor, Supervisor}}
\setcounter{@members}{1}        % Supervisor is always 1st member
% Members must be counted . . . up to seven non-supervisor members
\newcommand{\member}[1]{
  \addtocounter{@members}{1}    % Inc. num of members to include this new one.
  \ifcase\value{@members}
	 \or \or  
    \newcommand{\@memberb}{\@member{#1}} \or
    \newcommand{\@memberc}{\@member{#1}} \or
    \newcommand{\@memberd}{\@member{#1}} \or
    \newcommand{\@membere}{\@member{#1}} \or
    \newcommand{\@memberf}{\@member{#1}} \or
    \newcommand{\@memberg}{\@member{#1}}
  \else
     \ClassError{dukedisseratation.cls}
        {Thesis format error.  Too many committee members.} 
  \fi
}
% Print a committee member's name with a signature line
\newcommand{\@member}[1]{
\parbox{2.8in}{%
  \vskip 6.5ex  % Leave some room for signature
  \raisebox{-8pt}[0pt][17pt]{\rule{2.8in}{.5pt}}\par    % Print line.
  \hfil \raisebox{0pt}[0pt][0pt]{#1} \hfil     % Print member name below.
  }
}


% -----------------------------------------------------------------------
% TITLE PAGES:
% a) make title page and copyright page
% b) if we're making g-school approved vers, make UMI abs page
% -----------------------------------------------------------------------
\renewcommand\maketitle{\par
  \begingroup
    \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
    \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\parindent 1em\noindent
            \hb@xt@1.8em{%
                \hss\@textsuperscript{\normalfont\@thefnmark}}##1}%
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@maketitle
  \endgroup
  \setcounter{footnote}{0}%
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
\def\@maketitle{%
  \newpage
  \thispagestyle{empty}
 \linespread{1.5}                        %comando per impostare l'interlinea

\centering
\par
\vspace{6pt}
%\begin{tabular}{p{5cm}p{5cm}}
\includegraphics[width=.16\textwidth]{logo.png} \hspace{0.5\textwidth}
\includegraphics[width=.16\textwidth]{cern_logo.jpg}\\
%\end{tabular}
\par
\vspace{10pt}
\hrule 
\par
\vspace{18pt}
\par
\begin{large}\textbf{Ph.D. thesis}\\
\par
\vspace{2pt}
\par
December 2014 \\ 
\par
\vspace{8pt}
\par
\end{large} 
\begin{Large}
{\bf Corso di Dottorato in Fisica e Astronomia - Ciclo XXVI}\\
\vspace{-5pt}
Dipartimento di Fisica G.Occhialini\\
\vspace{-10pt}
Universit\`a degli Studi di Milano-Bicocca\\
\vspace{-10pt}
%y\\
%\vspace{-10pt}
%Institut de F\'isica d'Altes Energies\\
\end{Large}
\vspace{80pt}
{\huge \bfseries Study of time profiles} \\
\vspace{6pt}
{\huge \bfseries of heavy scintillating crystals} \\ 
\vspace{6pt}
%{\huge \bfseries at High Luminosity LHC}\\
%\vspace{6pt}
%{\huge \bfseries }
\vspace{80pt} 
\centering
\begin{tabular}{p{10cm}p{9cm}}
\large Doctoral Student &  \\
\Large \bfseries Nicolas Di Vara & \\
 & \\
 & \\
 & \large Tutor \\
 &\Large \bfseries Prof. Marco Paganoni\\
 &\large Universit\`a degli Studi di Milano-Bicocca\\
 &\large Dipartimento di Fisica G.Occhialini\\
 %& \\
 %& \\
 %& \large External Supervisor \\
 %&\Large \bfseries Dr. Etiennette Auffray\\
 %&\large CERN -- PH-CMX\\
 %& \\
 %& \\
\end{tabular}
\vspace{98pt} \\
\hrule \vspace{6pt}
\large 

\begin{textblock}{1}(11.5,13.5)
\includegraphics[scale=0.7]{Logo_Marie-Curie}
\end{textblock}
\begin{textblock}{1}(1.5,13.5)
\includegraphics[scale=0.3]{Entervision}
\end{textblock}



}

\newcommand\@UMIabstract{%
	\newpage
	\thispagestyle{empty}
	\null
	\normalbaselines
	\begin{center}
	{\Large \sc \underline{Abstract} \par}
	%{\normalsize (\@subject) \par }
	\vskip 1em%
	{\Large \@title \par}
	\vskip 1em%
	{\normalsize by \par }
	\vskip 1em%
	{\large \@author \par }
	  \vskip 1em%
	{\normalsize Department of \@department \par Duke University }
	\vskip 4ex%
	Date: \makebox[2in]{\hrulefill}\par\noindent
	%\vskip 1em%
	%\vfill
   {\small Approved:\par}%
	\@printsiglines
	\vfill
   \par \normalbaselines \noindent
   {\normalsize%
   An abstract of a dissertation submitted in partial fulfillment of the 
   requirements for 
	\par the degree of Doctor~of~Philosophy in the Department~of~\@department
	\par in the Graduate~School of Duke~University } \par
	{\normalsize \number\year}
   \end{center}% 
	\newpage
}

% Member signature lines function
% Print the committee members defined by the user.
% 0.4 -- removed 2-up layout, so page is ugly again.
\newcounter{@membersprinted}

\newcommand\@printsiglines{%
 \setcounter{@membersprinted}{0}
    \loop
      \ifnum \value{@membersprinted} < \value{@members}
         \addtocounter{@membersprinted}{1}
         \ifcase\value{@membersprinted}
           \or
           \@membera \par \or
           \@memberb \par \or
           \@memberc \par \or
           \@memberd \par \or
           \@membere \par \or
           \@memberf \par \or
			\else \typeout{Too many committee members defined!}
         \fi
    \repeat
}%

% Copyright page
\newcommand\@copyrightpage{%
	\newpage
	\thispagestyle{empty}
	\normalbaselines
	\null
	\vfill
	\begin{center}
		Copyright \copyright\enspace \number\year\enspace by \@author \par
		\@copyrighttext
	\end{center}
	\newpage
}%

% G-school does not allow parts!
\renewcommand\part{%
 \ClassWarning{Grad School guidelines forbid the use of parts!}
}
% % Modified the part env to start arabic page numbering 
% \renewcommand\part{%
%   \if@openright
%     \cleardoublepage
%   \else
%     \clearpage
%   \fi
%    \if@frontmatter
% 	   \@frontmatterfalse
% 	   \pagenumbering{arabic}
% 		\setcounter{page}{1}
% 	\fi
%   \thispagestyle{plain}%
%   \@tempswafalse
%   \null\vfil
%   \secdef\@part\@spart}
% \ifthenelse{\boolean{oldstyle}}{ }
% {
%   \def\@part[#1]#2{%
%   \ifnum \c@secnumdepth >-2\relax
%       \refstepcounter{part}%
%       \addcontentsline{toc}{part}{\thepart\hspace{1em}#1}%
%     \else
%       \addcontentsline{toc}{part}{#1}%
%     \fi
%     \markboth{}{}%
%     {\centering
%      \interlinepenalty \@M
%      \normalfont
%      \ifnum \c@secnumdepth >-2\relax
% 	  {\large \bfseries Part} \par {\Huge\bfseries \thepart}
%        \par
%      \fi
%      \vskip 20\p@
%      \normalbaselines \huge \bfseries #2\par}%
%     \@endpart}
% }

%-------------------------------------------------------------------------
% Chapter format:
%-------------------------------------------------------------------------
\def\@chapter[#1]#2{\ifnum \c@secnumdepth >\m@ne
                         \refstepcounter{chapter}%
								 % Done with frontmatter?
								 \if@frontmatter
								     \@frontmatterfalse
									  \pagenumbering{arabic}
									  \setcounter{page}{1}
								 \fi
                         \typeout{\@chapapp\space\thechapter.}%
                         \addcontentsline{toc}{chapter}%
                                   {\protect\numberline{\thechapter}#1}%
                    \else
                      \addcontentsline{toc}{chapter}{#1}%
                    \fi
                    \chaptermark{#1}%
                    \addtocontents{lof}{\protect\addvspace{10\p@}}%
                    \addtocontents{lot}{\protect\addvspace{10\p@}}%
                    \@makechapterhead{#2}%
                    \@afterheading
						  \normalbaselines
						  \@textspace  % double-spaced chapter text
}
% Format for normal chapters (and appendicies)
\ifthenelse{\boolean{oldstyle}}{ }
{%
\def\@makechapterhead#1{%
\vspace*{1in} % Leave space at top of page
  { 
  \parindent \z@ \raggedright \normalfont
		  \if@inappendix
		  % Include the word 'Appendix'
		  \makebox[\textwidth][r]{\Huge\bfseries \@chapapp\space\thechapter} 
		  \else
		  % Don't include the word 'Chapter'
		  \makebox[\textwidth][r]{\Huge\bfseries \thechapter} 
		  \fi
        \par\nobreak
        \vskip 10\p@
    \interlinepenalty\@M
	 % Title format
	 \parbox{\textwidth}{ \flushright{%
	  \normalbaselines \LARGE  #1  \par\nobreak }}
    \vskip 40\p@
  }%
  \vspace*{50\p@}%
  }

}

% A non-mainmatter chapter that appears in the ToC
\def\nmchapter#1{   
	\chapter*{#1}
   \addcontentsline{toc}{chapter}{#1}%
	\thispagestyle{plain}
	\normalbaselines
	\@textspace
}



%-------------------------------------------------------------------------
% Section format:
% \@startsection {NAME}{LEVEL}{INDENT}{BEFORESKIP}{AFTERSKIP}{STYLE}
%            optional * [ALTHEADING]{HEADING}
%-------------------------------------------------------------------------
\ifthenelse{\boolean{oldstyle}}{%
\renewcommand\section{\@startsection {section}{1}{\z@}%
                                   {-3.5ex \@plus -1ex \@minus -.2ex}%
                                   {2.3ex \@plus.2ex}%
                              {\normalbaselines\normalfont\Large\bfseries}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
                              {\normalbaselines\normalfont\large\bfseries}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
                              {\normalbaselines\normalfont\normalsize\bfseries}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                    {3.25ex \@plus1ex \@minus.2ex}%
                                    {-1em}%
                              {\normalbaselines\normalfont\normalsize\bfseries}}
\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\parindent}%
                                       {3.25ex \@plus1ex \@minus .2ex}%
                                       {-1em}%
                              {\normalbaselines\normalfont\normalsize\bfseries}}
}
{%
\renewcommand\section{\@startsection {section}{1}{\z@}%
                                   {-3.5ex \@plus -1ex \@minus -.2ex}%
                                   {2.3ex \@plus.2ex}%
					{\normalbaselines \normalfont\large}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
				  {\normalbaselines \normalfont\normalsize\it}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
				  {\normalbaselines \normalfont\normalsize\it}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                    {3.25ex \@plus 1ex \@minus.2ex}%
                                    {-1em}%
				 {\normalbaselines \normalfont\small\it}}
\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\parindent}%
                                       {3.25ex \@plus 1ex \@minus .2ex}%
                                       {-1em}%
				 {\normalbaselines \normalfont\small\it}}
}



\newenvironment{symbollist}
{%
\normalbaselines
\begin{list}{ }{%
	\addtolength{\topsep}{0.5\@SimSpace}
	\addtolength{\itemsep}{0.5\@SimSpace}
	\setlength{\labelwidth}{0.24\textwidth}
	\setlength{\labelsep}{2em}
	\setlength{\parsep}{0pt}
	\setlength{\leftmargin}{\labelwidth}
	\setlength{\rightmargin}{0pt}
	}
}
{ \end{list} } 
\renewcommand\appendix{\par
  \@inappendixtrue
  \setcounter{chapter}{0}%
  \setcounter{section}{0}%
  \gdef\@chapapp{\appendixname}%
  \gdef\thechapter{\@Alph\c@chapter}
}

%----------------------------------------------------------------
% Figure format
%----------------------------------------------------------------
% Note smallcaps 'Figure' instead of bold
\ifthenelse{\boolean{oldstyle}}{ }{%
\def\fnum@figure{{\sc \figurename\nobreakspace\thefigure}}
}
\setlength\abovecaptionskip{\z@} % reduced from 10pt
\setlength\belowcaptionskip{12pt plus 12 pt minus 12pt} % increased from 0\p@
% Single space captions
\long\def\@makecaption#1#2{%
  \vskip\abovecaptionskip
  \sbox\@tempboxa{\normalbaselines #1: #2}%
  \ifdim \wd\@tempboxa >\hsize
   \normalbaselines #1: #2\par
  \else
    \global \@minipagefalse
	 \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip
}



%---------------------------------------------------------------------
% Table of contents, list of figures, list of tables
%---------------------------------------------------------------------
% Single space entries
\renewcommand\tableofcontents{%
    \chapter*{\contentsname
        \@mkboth{%
           \MakeUppercase\contentsname}{\MakeUppercase\contentsname}}%
	 \normalbaselines
	 \@starttoc{toc}%
}
% Used \addvspace{\@SimSpace} to simulate double-spacing
\renewcommand*\l@section{{\protect\addvspace{\@SimSpace}}\@dottedtocline{1}{1.5em}{2.3em}}
\renewcommand*\l@subsection{{\protect\addvspace{\@SimSpace}}\@dottedtocline{2}{3.8em}{3.2em}}
\renewcommand*\l@subsubsection{{\protect\addvspace{\@SimSpace}}\@dottedtocline{3}{7.0em}{4.1em}}
\renewcommand*\l@paragraph{{\protect\addvspace{\@SimSpace}}\@dottedtocline{4}{10em}{5em}}
\renewcommand*\l@subparagraph{{\protect\addvspace{\@SimSpace}}\@dottedtocline{5}{12em}{6em}}
% Single spacing again . . .
\renewcommand\listoffigures{%
    \chapter*{\listfigurename}%
	 \addcontentsline{toc}{chapter}{\listfigurename}%
      \@mkboth{\MakeUppercase\listfigurename}%
              {\MakeUppercase\listfigurename}%
	 \normalbaselines
	 \@starttoc{lof}%
    }
% Used \addvspace{\@SimSpace} to simulate double-spacing
\renewcommand*\l@figure{{\protect\addvspace{\@SimSpace}}\@dottedtocline{1}{1.5em}{2.3em}}
% And again with single spacing . . .
\renewcommand\listoftables{%
    \chapter*{\listtablename}%
	 \addcontentsline{toc}{chapter}{\listtablename}%
      \@mkboth{\MakeUppercase\listtablename}%
              {\MakeUppercase\listtablename}%
	 \normalbaselines
	 \@starttoc{lot}%
}
\renewcommand*\l@table{{\protect\addvspace{\@SimSpace}}\@dottedtocline{1}{1.5em}{2.3em}}


%------------------------------------------------------------------------
% Bibliography
%------------------------------------------------------------------------
% You guessed it, single spacing
\renewenvironment{thebibliography}[1]{%
		\phantomsection
    	\addcontentsline{toc}{chapter}{\bibname}
		\normalbaselines % hello!
		\chapter*{\bibname}%
      \@mkboth{\MakeUppercase\bibname}{\MakeUppercase\bibname}%
      \list{\@biblabel{\@arabic\c@enumiv}}%
           {\settowidth\labelwidth{\@biblabel{#1}}%
			  \addtolength{\itemsep}{0.5\@SimSpace} % 'double-spacing'
            \leftmargin\labelwidth
            \advance\leftmargin\labelsep
            \@openbib@code
            \usecounter{enumiv}%
            \let\p@enumiv\@empty
            \renewcommand\theenumiv{\@arabic\c@enumiv}}%
      \sloppy
      \clubpenalty4000
      \@clubpenalty \clubpenalty
      \widowpenalty4000%
      \sfcode`\.\@m
}


%-----------------------------------------------------------------------
% Footnote formatting
%-----------------------------------------------------------------------
\renewcommand\@makefntext[1]{%
    \parindent 1em%
    \noindent
	 \hb@xt@1em{\hss\@makefnmark} \normalbaselines #1}
% Footnote spacing -- looser spacing looks better with double-spaced text
\setlength{\footnotesep}{ 14pt}
\skip\footins 8pt plus 2pt minus 4pt  % Space between last line of body text 
	                                   % and first line of footnote


%-----------------------------------------------------------------------
% Biography
%-----------------------------------------------------------------------
\newcommand\biography{%
	\if@MS
		\ClassWarning{dukedissertation}{No biography for MS thesis.}
	\fi
		\nmchapter{\biographyname}


}

%-----------------------------------------------------------------------
% Introduction
%-----------------------------------------------------------------------
\newcommand\introduction{%
	\if@MS
	\ClassWarning{dukedissertation}{No introduction for MS thesis.}
	\fi
		\@frontmatterfalse
		\pagenumbering{arabic}
		\nmchapter{Introduction}
}

\newcommand\front{%
%\nmchapter{\loaname}
}

%-----------------------------------------------------------------------
% Dedication
%-----------------------------------------------------------------------
\newcommand\dedication{%
%\nmchapter{\loaname}
}


%-----------------------------------------------------------------------
% List of Abbr.
%-----------------------------------------------------------------------
\newcommand\abbreviations{%
	\nmchapter{\loaname}
}


%-----------------------------------------------------------------------
% Acknowledgements
%-----------------------------------------------------------------------
\newcommand\acknowledgements{%
	\nmchapter{\ackname}
}


%-----------------------------------------------------------------------
% Abstract -- just another non-mainmatter chapter
%-----------------------------------------------------------------------
\renewcommand\abstract{%
  	\nmchapter{\abstractname}
}




%-----------------------------------------------------------------------
% Body text format
%-----------------------------------------------------------------------
\pagestyle{plain}
\@textspace
\raggedbottom % Allow flexibility in text height per page

%----------------------------
% Frontmatter proccessing hack --
% Set page numbering to roman.  @frontmatter
% trips to false when the first numbered (non-starred) chapter is included.
%----------------------------
\@frontmattertrue
\pagenumbering{roman}


\endinput
