# TAPAS View Packages

This is a central repository for the view packages (XSLT, CSS, JS, etc.) 
used to generate publication formats for the TAPAS platform.

Each package should be contained within a single directory which
itself is at the root level of this repository (i.e., a sibling of
this README file). Each view package should be defined by a single
<tt>config.xml</tt> file in said directory.

Each package should be (pretty much) entirely self-contained. That is,
all the higher-level code that operates on TEI files and produces
output should be within the package directory, or in the `common/`
directory. (Thus if two packages make use of the same XSLT program,
they either need two copies of it, or it should be stored in
`common/`.)

Note that this does not include utilities for running that code (e.g.,
the Saxon <tt>.jar</tt> file) or for creating it (e.g., the schema for
XSLT or for <tt>config.xml</tt> files). Our presumption is code
written for a package should independant of processor version. (Cross
your fingers.)
