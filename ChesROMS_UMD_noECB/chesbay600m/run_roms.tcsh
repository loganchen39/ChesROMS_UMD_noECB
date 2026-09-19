#!/bin/bash
# #!/bin/tcsh

#PBS  -A UMCP0014   
#PBS  -l walltime=12:00:00
# #PBS  -l walltime=02:00:00
# #PBS  -l select=1:ncpus=8:mpiprocs=8
#PBS  -l select=1:ncpus=80:mpiprocs=80
# #PBS  -l select=1:ncpus=1:mpiprocs=1 
#PBS  -N roms
#PBS  -j oe
#PBS  -q main
#PBS  -l job_priority=premium
# #PBS  -q preempt
#PBS -M lchen2@umd.edu

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/glade/u/home/lgchen/lgchen_work/project/OISSH_JEDI/JEDI-SSH_Derecho/build_v03_newDiffusion_email_2024-09-05/lib
echo $LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/glade/work/epicufsrt/contrib/spack-stack/derecho/spack-stack-1.7.0/envs/ue-gcc/install/gcc/12.2.0/netcdf-c-4.9.2-kpjnvwg/lib:/glade/work/epicufsrt/contrib/spack-stack/derecho/spack-stack-1.7.0/envs/ue-gcc/install/gcc/12.2.0/netcdf-fortran-4.6.1-vuce2oo/lib
echo $LD_LIBRARY_PATH

ulimit -s unlimited

mpirun -np 80 ./romsM roms_cb600m.in
 
exit 0
