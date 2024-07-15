Flow for cleaning up clang-tidy issue
=====================================


Identification and documentation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First identify the CMake target you intend to clean-up.

eg. a third-party component you wish to review the clang-tidy issues or some other user defined target.

1. Configure for Clang Tidy checks on

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DSTATIC_ANALYSIS=ON -DUSE_CLANG_TIDY=ON ../.
   cmake --build . --config Debug

2. Run the build process on your single CMake target - eg: foo_target

.. code:: bash

   ninja -k 100000 foo_target | tee junk.txt
   echo "Total number of clang-tidy issues:"
   grep -E "error:" -c junk.txt
   echo "Breakdown of clang-tidy issues:"
   grep -E "error:" junk.txt | sed -n 's/.*\[\(.*\),-warnings-as-errors\]$/\1/p' | sort | uniq -c | sort -nr

3. Create a list to ignore them in the CMakeLists.txt file:

.. code:: bash

    echo "target_clang_tidy_definitions(TARGET foo_target\n  CHECKS \n"
    grep -E "error:" junk.txt | sed -n 's/.*\[\(.*\),-warnings-as-errors\]$/-\1/p' | sed -e 's/,/\n-/g' | sort | uniq
    echo ")"

4. Copy that list to the foo_target's CMakeLists.txt file and re-run the build

.. code:: bash

   ninja -k 100000 foo_target | tee junk.txt

And confirm building without issue - repeat the process if you have additional errors until it is considered clean.

At this point you have the list of issues related to that target documented.  Now on to cleaning them.

Cleanup Flow
^^^^^^^^^^^^

Now that the lists of issues are documented in the CMakeLists.txt you can take this and now start to work on fixing the issues.

If there is no set of unit tests to confirm the changes, I suggest limiting it to formatting, style and auto-FIX issues only.

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DSTATIC_ANALYSIS=ON -DUSE_CLANG_TIDY=ON -DCLANG_TIDY_FIX=ON ../.
   cmake --build . --config Debug

Now to limit the tool from doing too much all at once, group specific issues and comment those out in the CMakeLists.txt file.
Clean up the issues identified and suggest committing to git after every loop.

TODO(phelter): More on how to group later.