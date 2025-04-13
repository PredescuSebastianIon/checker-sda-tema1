#!/bin/bash

SRC_DIR="../src"
TARGET="$SRC_DIR/tema"
INPUT_DIR="./in_files"
OUTPUT_DIR="./out_files"

echo "Compiling your program"
(
	cd "$SRC_DIR"
	make clean
	make
)

if [ ! -f "$SRC_DIR/$TARGET" ]; then
	echo "Error!! Executable not found"
	exit 1
fi

PASS_COUNT=0
FAILED_COUNT=0

touch "$SRC_DIR/tema1.in"
echo ""
echo "------------------------------------"
echo ""
for i in $(seq 1 12); do
	#echo "$test_input"
	test_name="test$i"
	test_input="$INPUT_DIR/${test_name}".in
	expected_output="$OUTPUT_DIR/${test_name}".ref

	#echo "$expected_output"
	echo > "$SRC_DIR/tema1.out"
	if [ ! -f "$expected_output" ]; then
		echo "${test_name}: Warning! Nu exista fisierul ${test_name}.ref. Sarim peste acest test"
		continue
	fi

	cat "$test_input" > "$SRC_DIR/tema1.in"
	#Run the target
	#echo "running target: $TARGET"
	cd "$SRC_DIR"
	#"$TARGET"
	valgrind --leak-check=full --error-exitcode=99 --show-leak-kinds=all --track-origins=yes --verbose "$TARGET" > valgrind.log 2>&1
	VALGRIND_CODE=$?

	cd "../checker"
	if diff -q "$SRC_DIR/tema1.out" "$expected_output" > /dev/null; then
		echo -n "$test_name: PASSED 5/5"
		PASS_COUNT=$((PASS_COUNT + 1))
	else
		cat "$SRC_DIR/tema1.out"
		echo -n "$test_name: FAILED 0/5"
		FAILED_COUNT=$((FAILED_COUNT + 1))
	fi

	if [ $VALGRIND_CODE -eq 0 ]; then
		echo " | No memory leaks"
	else
		echo " | Memory leaks"
		echo "Please take test $i and run manually to see more detalies using:"
		echo "valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose ./tema"
	fi
done

echo ""
echo "------------------------------------"
echo ""
echo "Your final result: $((PASS_COUNT*5))/$(((PASS_COUNT+FAILED_COUNT)*5))"


#rm $SRC_DIR/tema1.in $SRC_DIR/tema1.out
