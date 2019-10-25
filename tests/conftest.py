import os
import glob
import cocotb_coverage.coverage as cov

def pytest_runtest_setup(item):
    print("Setting up", item)

# Post session coverage merging
def pytest_sessionfinish(session, exitstatus):
    print("\nSession finish phase ")
    updir = os.path.dirname
    testsd = updir(os.path.abspath(__file__))

    #TODO group coverage files
    cov_files = [f for f in glob.glob(testsd+"/sim_build/*coverage*")]
    try:
        _, filetype = os.path.splitext(cov_files[0])
    except IndexError:
        print("Can't extract filetype")
        print("Checking if sim_build folder exist: ", os.path.isdir(testsd+"/sim_build"))
        print("Checking count of collected cov files: ", len(cov_files))
        raise

    cov.merge_coverage(print, "merged_coverage"+filetype, *cov_files)
    '''
    print("Removing merged coverage files: ")
    for f in cov_files:
        print(f)
        try:
            os.remove(f)
        except:
            print(f"Error occured when trying to delete {f}")
            raise
    '''



