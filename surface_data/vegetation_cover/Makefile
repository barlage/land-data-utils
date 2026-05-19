# Makefile 
#
.SUFFIXES:
.SUFFIXES: .o .f90

COMPILERF90    =       ifx
F90FLAGS       =       
NETCDFMOD      =       -I${netcdf_fortran_ROOT}/include
NETCDFLIB      =       -L${netcdf_fortran_ROOT}/lib -lnetcdff

OBJS =	create_vegetation_cover_nofill.o create_vegetation_cover_fill.o

all:	create_vegetation_cover_nofill.exe create_vegetation_cover_fill.exe

.f90.o:
	$(COMPILERF90) -c $(F90FLAGS) $(NETCDFMOD) $(*).f90

create_vegetation_cover_nofill.exe: create_vegetation_cover_nofill.o
	$(COMPILERF90) -o $(@) $(F90FLAGS) create_vegetation_cover_nofill.o $(NETCDFLIB)

create_vegetation_cover_fill.exe: create_vegetation_cover_fill.o
	$(COMPILERF90) -o $(@) $(F90FLAGS) create_vegetation_cover_fill.o $(NETCDFLIB)

clean:
	rm -f *.exe *.o

