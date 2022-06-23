# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

# For Use EMSES #############
export PATH="$PATH:/opt/KDK/bin"
module switch PrgEnv-cray PrgEnv-intel
module load fftw
module load hdf5-parallel/1.10.0_intel-17.0-impi-2017.1
module load cray-hdf5-parallel
module load git

module load anaconda3/2019.10
module switch intel/18.0.5.274 intel/19.1.2.254

# For self-made command #####
export PATH="~/.local/bin:$PATH"

# alias for camptools #######
alias js="job_status"  # show all running job output (= qcat -o <job-id>)
alias je="job_status -e"  # show all running job error output (= qcat -e <job-id>)
alias jl="joblist"  # show all runnging job status (≒ qs; qgroup)
alias chk="checkpoint"
