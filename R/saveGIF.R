##' Convert images to a single animation file (typically GIF) using ImageMagick or GraphicsMagick.
##' This function opens a graphical device (specified in \code{ani.options('ani.dev')})
##' first to generate a sequence of images based on \code{expr}, then makes use
##' of the command \command{convert} in `ImageMagick' to convert these images to
##' a single animated movie (as a GIF or MPG file). An alternative software
##' package is GraphicsMagick (use \code{convert = 'gm convert'}), which is
##' smaller than ImageMagick.
##'
##' This function calls \code{\link{im.convert}} (or \code{\link{gm.convert}},
##' depending on the argument \code{convert}) to convert images to a single
##' animation.
##'
##' The advantage of this function is that it can create a single movie file,
##' however, there are two problems too: (1) we need a special (free) software
##' ImageMagick or GraphicsMagick; (2) the speed of the animation will be beyond
##' our control, as the \code{interval} option is fixed. Other approaches
##' in this package may have greater flexibilities, e.g. the HTML approach (see
##' \code{\link{saveHTML}}).
##'
##' See \code{\link{ani.options}} for the options that may affect the output, e.g.
##' the graphics device (including the height/width specifications), the file
##' extension of image frames, and the time interval between image frames, etc.
##' Note that \code{ani.options('interval')} can be a numeric vector!
##' @aliases saveGIF saveMovie
##' @param expr an expression to generate animations; use either the animation
##'   functions (e.g. \code{brownian.motion()}) in this package or a custom
##'   expression (e.g. \code{for(i in 1:10) plot(runif(10), ylim = 0:1)}).
##' @param movie.name file name of the movie (with the extension)
##' @param img.name file name of the sequence of images (`pure' name; without
##'   any format or extension)
##' @param convert the command to convert images (default to be
##'   \command{convert} (i.e. use ImageMagick), but might be \command{imconvert}
##' under some Windows platforms); can be \command{gm convert} in order to use
##' GraphicsMagick; see the 'Note' section for details
##' @param cmd.fun a function to invoke the OS command; by default
##' \code{\link[base]{system}}
##' @param clean whether to delete the individual image frames
##' @param \dots other arguments passed to \code{\link{ani.options}}, e.g.
##'   \code{ani.height} and \code{ani.width}, ...
##' @return An integer indicating failure (-1) or success (0) of the converting
##'   (refer to \code{\link[base]{system}} and \code{\link{im.convert}}).
##' @note See \code{\link{im.convert}} for details on the configuration of
##'   ImageMagick (typically for Windows users) or GraphicsMagick.
##'
##' It is recommended to use \code{ani.pause()} to pause between animation
##' frames in \code{expr}, because this function will only pause when called in
##' a non-interactive graphics device, which can save a lot of time.
##' See the demo \code{'Xmas2'} for example (\code{demo('Xmas2', package = 'animation')}).
##'
##' \code{\link{saveGIF}} has an alias \code{\link{saveMovie}}
##' (i.e. they are essentially identical); the latter name is for
##' compatibility to older versions of this package (< 2.0-2). It is
##' recommended to use \code{\link{saveGIF}} to avoid confusions
##' between \code{\link{saveMovie}} and \code{\link{saveVideo}}.
##' @author Yihui Xie <\url{http://yihui.name}>
##' @seealso \code{\link{im.convert}}, \code{\link{gm.convert}},
##' \code{\link{saveSWF}}, \code{\link{saveVideo}},
##' \code{\link[base]{system}}, \code{\link[grDevices]{png}},
##' \code{\link{saveLatex}}, \code{\link{saveHTML}}
##' @references
##' ImageMagick: \url{http://www.imagemagick.org/script/convert.php}
##'
##' GraphicsMagick: \url{http://www.graphicsmagick.org}
##'
##' \url{http://animation.yihui.name/animation:start}
##' @keywords dynamic device utilities
##' @examples
##'
##' ## make sure ImageMagick has been installed in your system
##' saveGIF({for(i in 1:10) plot(runif(10), ylim = 0:1)})
##'
##' ## if the above conversion was successful, the option 'convert' should
##' ##    not be NULL under Windows
##' ani.options('convert')
##' ## like "C:/Software/LyX/etc/ImageMagick/convert.exe"
##'
##' saveGIF({brownian.motion(pch = 21, cex = 5, col = "red", bg = "yellow")},
##'     movie.name = 'brownian_motion.gif',
##'     interval = 0.1, nmax = 30, ani.width = 600, ani.height = 600)
##'
saveGIF = function(expr, movie.name = "animation.gif", img.name = "Rplot",
             convert = "convert", cmd.fun = system, clean = TRUE, ...) {
    oopt = ani.options(...)
    on.exit(ani.options(oopt))
    ## create images in the temp dir
    owd = setwd(tempdir())
    on.exit(setwd(owd), add = TRUE)

    file.ext = ani.options('ani.type')

    ## clean up the files first
    unlink(paste(img.name, "*.", file.ext, sep = ""))

    ## draw the plots and record them in image files
    ani.dev = ani.options('ani.dev')
    if (is.character(ani.dev)) ani.dev = get(ani.dev)
    img.fmt = paste(img.name, "%d.", file.ext, sep = "")
    img.fmt = file.path(getwd(), img.fmt)
    if ((use.dev <- ani.options('use.dev')))
        ani.dev(img.fmt, width = ani.options('ani.width'),
                height = ani.options('ani.height'))
    owd1 = setwd(owd)
    eval(expr)
    setwd(owd1)
    if (use.dev) dev.off()

    ## compress PDF files
    if (file.ext == 'pdf' &&
        ((use.pdftk <- !is.null(ani.options('pdftk'))) ||
         (use.qpdf <- !is.null(ani.options('qpdf'))))) {
        for (f in list.files(path = dirname(img.name), pattern =
                             sprintf('^%s[0-9]*\\.pdf$', img.name), full.names = TRUE))
            if (use.qpdf) qpdf(f) else if (use.pdftk) pdftk(f)
    }

    img.files = sprintf(img.fmt, seq_len(length(list.files(pattern =
                        paste(img.name, "[0-9]+\\.", file.ext, sep = "")))))
    ## convert to animations
    im.convert(img.files, output = movie.name, convert = convert,
               cmd.fun = cmd.fun, clean = clean)
}

saveMovie = saveGIF