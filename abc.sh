if [[ -z "${CLEAN_HOME}" ]]; then
	echo "CLEAN_HOME undefined, do you have Clean installed?" >&2
	exit 1
fi

if [[ -z "${TMPDIR}" ]]; then
	TMPDIR="/tmp"
fi

local_path=$(readlink -f "$0")
local_path=$(dirname "${local_path}")

syslink_cmd=(gcc -no-pie)

out_file="a.out"
in_file=""
clmlink_args=()
codegen_args=()
syslink_args=()
use_runtime=true

for i in "$@"; do
	case "$i" in
	-o=*)
		out_file="${i#*=}"
		;;
	--syslink=*)
		syslink_args+=("${i#*=}")
		;;
	--clmlink=*)
		clmlink_args+=("${i#*=}")
		;;
	--codegen=*)
		codegen_args+=("${i#*=}")
		;;
	--no-rts)
		use_runtime=false
		;;
	*)
		in_file="${i}"
		;;
esac
done

codegen_tmp=$(mktemp "${TMPDIR}/codegenXXXXXX")

"${CLEAN_HOME}/lib/exe/cg" "${codegen_args[@]}" "${in_file}" -o "${codegen_tmp}"

clmlink_tmp=$(mktemp "${TMPDIR}/clmlinkXXXXXX")

if "${use_runtime}"; then
	"${CLEAN_HOME}/lib/exe/linker" "${clmlink_tmp}" "${codegen_tmp}" "${CLEAN_HOME}/lib/StdEnv/Clean System Files/_startup.o" "${CLEAN_HOME}/lib/StdEnv/Clean System Files/_system.o" "${clmlink_args[@]}"
else
	"${CLEAN_HOME}/lib/exe/linker" "${clmlink_tmp}" "${codegen_tmp}" "${clmlink_args[@]}"
fi

rm "${codegen_tmp}"

if "${use_runtime}"; then
	"${syslink_cmd[@]}" -o "${out_file}" "${clmlink_tmp}" "${local_path}/defaults.o" "${syslink_args[@]}"
else
	"${syslink_cmd[@]}" -o "${out_file}" "${clmlink_tmp}" "${syslink_args[@]}"
fi

rm "${clmlink_tmp}"
