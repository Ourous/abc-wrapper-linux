if [[ -z "${CLEAN_HOME}" ]]; then
	echo "CLEAN_HOME undefined, do you have Clean installed?" >&2
	exit 1
fi

if [[ -z "${TMPDIR}" ]]; then
	TMPDIR="/tmp"
fi

local_path=$(readlink -f "$0")
local_path=$(dirname "${local_path}")

syslink_cmd="gcc -no-pie"

clmlink_args=""
codegen_args=""
syslink_args=""
out_file="a.out"

for i in "$@"; do
	case "$i" in
	-o=*)
		out_file="${i#*=}"
		;;
	--syslink=*)
		syslink_args="${i#*=}"
		;;
	--clmlink=*)
		clmlink_args="${i#*=}"
		;;
	--codegen=*)
		codegen_args="${i#*=}"
		;;
	*)
		file_name="${i}"
		;;
esac
done


codegen_tmp=$(mktemp "${TMPDIR}/codegenXXXXXX")

eval "${CLEAN_HOME}/lib/exe/cg ${codegen_args} ${file_name} -o ${codegen_tmp}"

clmlink_tmp=$(mktemp "${TMPDIR}/clmlinkXXXXXX")

eval "${CLEAN_HOME}/lib/exe/linker ${clmlink_tmp} ${codegen_tmp} ${CLEAN_HOME}/lib/StdEnv/Clean\ System\ Files/_startup.o ${CLEAN_HOME}/lib/StdEnv/Clean\ System\ Files/_system.o ${clmlink_args}"

rm "${codegen_tmp}"

eval "${syslink_cmd} -o ${out_file} ${clmlink_tmp} ${local_path}/defaults.o ${syslink_args}"

rm "${clmlink_tmp}"
