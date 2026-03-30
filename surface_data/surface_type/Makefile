# Makefile 
#
.SUFFIXES:
.SUFFIXES: .o .f90

COMPILERF90    =       ifx
F90FLAGS       =       
NETCDFMOD      =       -I${netcdf_fortran_ROOT}/include
NETCDFLIB      =       -L${netcdf_fortran_ROOT}/lib -lnetcdff

all:	transfer_to_template.exe create_surface_type_nofill.exe

.f90.o:
	$(COMPILERF90) -c $(F90FLAGS) $(NETCDFMOD) $(*).f90

transfer_to_template.exe: transfer_to_template.o
	$(COMPILERF90) -o $(@) $(F90FLAGS) transfer_to_template.o $(NETCDFLIB)

create_surface_type_nofill.exe: create_surface_type_nofill.o
	$(COMPILERF90) -o $(@) $(F90FLAGS) create_surface_type_nofill.o $(NETCDFLIB)

clean:
	rm -f *.exe *.o

