"""Run batches of fsl GLM analysis.

Raises:
    RuntimeError: Failing shell commands.

"""
import argparse
import logging
import os
import re
import shlex
import shutil
import subprocess
import sys

from functools import partial
#from itertools import chain
#from typing import Union

import pandas as pd
from tqdm.contrib.concurrent import process_map
from pandas import read_csv

logger = logging.getLogger(__name__)
streamhdlr = logging.StreamHandler(stream=sys.stdout)
streamhdlr.setLevel(logging.INFO)
logger.addHandler(streamhdlr)
logger.setLevel(logging.DEBUG)


def run_command(scommand, capture_output=False):
    """Run a command with the shell.

    Arguments:
        scommand {str} -- Command to be executed.

    Keyword Arguments:
        capture_output {bool} -- Allow the output from the command to be accessed via the
            .stdout attribute on the returned CompletedProcess. (default: {False})

    Raises:
        RuntimeError: Raised if the command returns a non-zero return code.

    Returns:
        subprocess.CompletedProcess -- Result of subprocess.run.

    """
    logger.info("About to run:\n{}".format(scommand))
    sargs = shlex.split(scommand)
    if capture_output:
        process_results = subprocess.run(sargs, stdout=subprocess.PIPE)
    else:
        process_results = subprocess.run(sargs)
    if process_results.returncode:
        logger.error("Received non-zero return code: {}".format(process_results))
        raise RuntimeError("Received non-zero return code: {}".format(process_results))
    return process_results


def get_FileHandler(log_fname, debug_filelogging=True, overwrite=False):
    """Set up logging to a log file on disk.

    Args:
        log_fname (str): File path at which to create the log file.
        debug_filelogging (bool, optional): If True(default), emit maximal messages to
            log. When False, emits one step down, omitting many large log records mostly
            used for debugging.
        overwrite (bool, optional): Determines whether to overwrite any preexisting log
            file. Default False.

    Returns:
        logging.FileHandler: The set up handler.

    """
    logfile_handler = logging.FileHandler(log_fname, mode="w" if overwrite else "a")
    logfile_handler.setLevel(logging.DEBUG if debug_filelogging else logging.INFO)
    logfile_format = logging.Formatter(
        "%(asctime)s - %(levelname)s@%(name)s: %(message)s"
    )
    logfile_handler.setFormatter(logfile_format)
    return logfile_handler


def fill_in_template(template, params):
    """Fill in template placeholders according to params.

    Arguments:
        template {str} -- Template string.
        params {dict} -- Dict requires a key matching each template string placeholder
            variable name. Corresponding values will be inserted.

    Returns:
        str -- Populated template string.

    """
    return template.format(**params)

def parallelize_session_GLM(fsfTemplate,workingDir,runDir,):
    """
    Prepare the run-specific fsf file from fsfTemplate and run FEAT.

    Args:
        fsfTemplate (dict[str, str]): Template fsfs for each runType, typically read in from a
            file.
        runDir (str): Path to the folder for this run.
        runType (str): The run type. Dictates what template and which EVs to use.
    """
    # Grab the ID number of current input
    curRun = runDir[-2:]
    logger.info("Starting run {}".format(curRun))

    # Set parameters
    params = {}
    sourceDir = os.path.join(runDir, curRun + "-preprocess_CorrectST.feat")
    params["input_feat_file"] = os.path.join(sourceDir, "denoised_data")
    logger.debug(f'input_feat_file = {params["input_feat_file"]}')
    params["outputDir"] = os.path.join(runDir, f"GLMsingletrial_CorrectST.feat")
    logger.debug(f'outputDir = {params["outputDir"]}')
    # Update volume count
    cresult = run_command(
        f"sh getNumVolume.sh {str(params['input_feat_file'])}.nii.gz",
        capture_output=True,
    )
    params["numVolumes"] = int(cresult.stdout)
    logger.debug(f'numVolumes = {params["numVolumes"]}')
    # Update TR duration
    cresult = run_command(
        f"sh getTRDuration.sh {params['input_feat_file']}.nii.gz",
        capture_output=True,
    )
    params["TR_duration"] = float(cresult.stdout)
    logger.debug(f'TR_duration = {params["TR_duration"]}')

    # Set EV paths
    EVPrefix = "EVfiles/GLMsingletrial_run" + curRun + "_"
    params["trial1Path"] = os.path.join(workingDir, EVPrefix + "trial1.txt")
    logger.debug(f'trial1Path = {params["trial1Path"]}')
    params["trial2Path"] = os.path.join(workingDir, EVPrefix + "trial2.txt")
    logger.debug(f'trial2Path = {params["trial2Path"]}')
    params["trial3Path"] = os.path.join(workingDir, EVPrefix + "trial3.txt")
    logger.debug(f'trial3Path = {params["trial3Path"]}')
    params["trial4Path"] = os.path.join(workingDir, EVPrefix + "trial4.txt")
    logger.debug(f'trial4Path = {params["trial4Path"]}')
    params["trial5Path"] = os.path.join(workingDir, EVPrefix + "trial5.txt")
    logger.debug(f'trial5Path = {params["trial5Path"]}')
    params["trial6Path"] = os.path.join(workingDir, EVPrefix + "trial6.txt")
    logger.debug(f'trial6Path = {params["trial6Path"]}')
    params["trial7Path"] = os.path.join(workingDir, EVPrefix + "trial7.txt")
    logger.debug(f'trial7Path = {params["trial7Path"]}')
    params["trial8Path"] = os.path.join(workingDir, EVPrefix + "trial8.txt")
    logger.debug(f'trial8Path = {params["trial8Path"]}')
    params["trial9Path"] = os.path.join(workingDir, EVPrefix + "trial9.txt")
    logger.debug(f'trial9Path = {params["trial9Path"]}')
    params["trial10Path"] = os.path.join(workingDir, EVPrefix + "trial10.txt")
    logger.debug(f'trial10Path = {params["trial10Path"]}')
    params["trial11Path"] = os.path.join(workingDir, EVPrefix + "trial11.txt")
    logger.debug(f'trial11Path = {params["trial11Path"]}')
    params["trial12Path"] = os.path.join(workingDir, EVPrefix + "trial12.txt")
    logger.debug(f'trial12Path = {params["trial12Path"]}')
    params["trial13Path"] = os.path.join(workingDir, EVPrefix + "trial13.txt")
    logger.debug(f'trial13Path = {params["trial13Path"]}')
    params["trial14Path"] = os.path.join(workingDir, EVPrefix + "trial14.txt")
    logger.debug(f'trial14Path = {params["trial14Path"]}')
    params["trial15Path"] = os.path.join(workingDir, EVPrefix + "trial15.txt")
    logger.debug(f'trial15Path = {params["trial15Path"]}')
    params["trial16Path"] = os.path.join(workingDir, EVPrefix + "trial16.txt")
    logger.debug(f'trial16Path = {params["trial16Path"]}')
    params["trial17Path"] = os.path.join(workingDir, EVPrefix + "trial17.txt")
    logger.debug(f'trial17Path = {params["trial17Path"]}')
    params["trial18Path"] = os.path.join(workingDir, EVPrefix + "trial18.txt")
    logger.debug(f'trial18Path = {params["trial18Path"]}')
    params["trial19Path"] = os.path.join(workingDir, EVPrefix + "trial19.txt")
    logger.debug(f'trial19Path = {params["trial19Path"]}')
    params["trial20Path"] = os.path.join(workingDir, EVPrefix + "trial20.txt")
    logger.debug(f'trial20Path = {params["trial20Path"]}')
    params["trial21Path"] = os.path.join(workingDir, EVPrefix + "trial21.txt")
    logger.debug(f'trial21Path = {params["trial21Path"]}')
    params["trial22Path"] = os.path.join(workingDir, EVPrefix + "trial22.txt")
    logger.debug(f'trial22Path = {params["trial22Path"]}')
    params["trial23Path"] = os.path.join(workingDir, EVPrefix + "trial23.txt")
    logger.debug(f'trial23Path = {params["trial23Path"]}')
    params["trial24Path"] = os.path.join(workingDir, EVPrefix + "trial24.txt")
    logger.debug(f'trial24Path = {params["trial24Path"]}')
    params["trial25Path"] = os.path.join(workingDir, EVPrefix + "trial25.txt")
    logger.debug(f'trial25Path = {params["trial25Path"]}')
    params["trial26Path"] = os.path.join(workingDir, EVPrefix + "trial26.txt")
    logger.debug(f'trial26Path = {params["trial26Path"]}')
    params["trial27Path"] = os.path.join(workingDir, EVPrefix + "trial27.txt")
    logger.debug(f'trial27Path = {params["trial27Path"]}')
    params["trial28Path"] = os.path.join(workingDir, EVPrefix + "trial28.txt")
    logger.debug(f'trial28Path = {params["trial28Path"]}')
    params["trial29Path"] = os.path.join(workingDir, EVPrefix + "trial29.txt")
    logger.debug(f'trial29Path = {params["trial29Path"]}')
    params["trial30Path"] = os.path.join(workingDir, EVPrefix + "trial30.txt")
    logger.debug(f'trial30Path = {params["trial30Path"]}')
    params["trial31Path"] = os.path.join(workingDir, EVPrefix + "trial31.txt")
    logger.debug(f'trial31Path = {params["trial31Path"]}')
    params["trial32Path"] = os.path.join(workingDir, EVPrefix + "trial32.txt")
    logger.debug(f'trial32Path = {params["trial32Path"]}')
    params["trial33Path"] = os.path.join(workingDir, EVPrefix + "trial33.txt")
    logger.debug(f'trial33Path = {params["trial33Path"]}')
    params["trial34Path"] = os.path.join(workingDir, EVPrefix + "trial34.txt")
    logger.debug(f'trial34Path = {params["trial34Path"]}')
    params["trial35Path"] = os.path.join(workingDir, EVPrefix + "trial35.txt")
    logger.debug(f'trial35Path = {params["trial35Path"]}')
    params["trial36Path"] = os.path.join(workingDir, EVPrefix + "trial36.txt")
    logger.debug(f'trial36Path = {params["trial36Path"]}')
    params["trial37Path"] = os.path.join(workingDir, EVPrefix + "trial37.txt")
    logger.debug(f'trial37Path = {params["trial37Path"]}')
    params["trial38Path"] = os.path.join(workingDir, EVPrefix + "trial38.txt")
    logger.debug(f'trial38Path = {params["trial38Path"]}')
    params["trial39Path"] = os.path.join(workingDir, EVPrefix + "trial39.txt")
    logger.debug(f'trial39Path = {params["trial39Path"]}')
    params["trial40Path"] = os.path.join(workingDir, EVPrefix + "trial40.txt")
    logger.debug(f'trial40Path = {params["trial40Path"]}')
    params["trial41Path"] = os.path.join(workingDir, EVPrefix + "trial41.txt")
    logger.debug(f'trial41Path = {params["trial41Path"]}')
    params["trial42Path"] = os.path.join(workingDir, EVPrefix + "trial42.txt")
    logger.debug(f'trial42Path = {params["trial42Path"]}')
    params["trial43Path"] = os.path.join(workingDir, EVPrefix + "trial43.txt")
    logger.debug(f'trial43Path = {params["trial43Path"]}')
    params["trial44Path"] = os.path.join(workingDir, EVPrefix + "trial44.txt")
    logger.debug(f'trial44Path = {params["trial44Path"]}')
    params["trial45Path"] = os.path.join(workingDir, EVPrefix + "trial45.txt")
    logger.debug(f'trial45Path = {params["trial45Path"]}')
    params["trial46Path"] = os.path.join(workingDir, EVPrefix + "trial46.txt")
    logger.debug(f'trial46Path = {params["trial46Path"]}')
    params["trial47Path"] = os.path.join(workingDir, EVPrefix + "trial47.txt")
    logger.debug(f'trial47Path = {params["trial47Path"]}')
    params["trial48Path"] = os.path.join(workingDir, EVPrefix + "trial48.txt")
    logger.debug(f'trial48Path = {params["trial48Path"]}')
    params["trial49Path"] = os.path.join(workingDir, EVPrefix + "trial49.txt")
    logger.debug(f'trial49Path = {params["trial49Path"]}')
    params["trial50Path"] = os.path.join(workingDir, EVPrefix + "trial50.txt")
    logger.debug(f'trial50Path = {params["trial50Path"]}')
    params["testarray_postPath"] = os.path.join(workingDir, EVPrefix + "testarraypostcue.txt")
    logger.debug(f'testarray_postPath = {params["testarray_postPath"]}')
    params["testarray_retroPath"] = os.path.join(workingDir, EVPrefix + "testarrayretrocue.txt")
    logger.debug(f'testarray_retroPath = {params["testarray_retroPath"]}')

    # Create block specific fsf file
    blockGLMfsf = fill_in_template(fsfTemplate, params)
    blockGLMPath = os.path.join(runDir, "block" + curRun + "_GLMsingletrial_CorrectST.fsf")
    with open(blockGLMPath, "w") as file:
        file.write(blockGLMfsf)

    # run FEAT
    curDir = os.getcwd()
    os.chdir(runDir)
    scommand = 'feat "' + blockGLMPath + '"'
    results = run_command(scommand)
    logger.debug(f"feat CLI run results: {results}")

    # Copy reg folder from preprocess run so it's available for higher order GLM runs
    regSource = os.path.join(sourceDir, "reg")
    regDest = os.path.join(f'{params["outputDir"]}', "reg")
    logger.debug(f"Copying registration from {regSource} to {regDest}.")
    shutil.copytree(regSource, regDest, copy_function=shutil.copy)
    os.chdir(curDir)


def session_GLM(workingDir, inputFolders, maxProcesses=7) -> None:
    """Run initial session GLMs using fsl's FEAT.

    Arguments:
        workingDir {str} -- Path to directory containing template fsf files.
        inputFolders {[str]} -- List of paths to the runs to process.
    """
    logger.addHandler(get_FileHandler(os.path.join(workingDir, "GLM.log")))
    with open(os.path.join(workingDir, "GLMsingletrial_template.fsf"), "r") as file:
        fsfTemplate = file.read()
        logger.debug(f"Read GLMsingletrialTemplate from {file.name}.")
    
    fixed_parallelize_session_GLM = partial(
        parallelize_session_GLM, fsfTemplate, workingDir
    )
    process_map(
        fixed_parallelize_session_GLM,
        inputFolders,
        max_workers=maxProcesses,
    )

def session_GLM_CLI(args):
    workingDir = os.path.abspath(os.path.expanduser(args.workingDir))
    # Use to_process.txt to define input run folders
    toProcess = os.path.join(workingDir, "to_process_main.txt")
    inputFolders = []
    with open(toProcess, "r") as inputs:
        for inputFilename in inputs:
            # Grab the ID number of current input
            cur_nifii = inputFilename[0:2]
            inputFolders += [os.path.join(workingDir, "run" + cur_nifii)]
    session_GLM(workingDir, inputFolders)

def GLM_CLI(args: argparse.Namespace) -> None:
    workingDir = os.path.abspath(os.path.expanduser(args.workingDir))
    toProcess = os.path.join(workingDir, "to_process_main.txt")
    inputFolders = []
    with open(toProcess, "r") as inputs:
        for inputFilename in inputs:
            # Grab the ID number of current input
            cur_nifii = inputFilename[0:2]
            inputFolders += [os.path.join(workingDir, "run" + cur_nifii)]
            
    args.func(workingDir, inputFolders, maxProcesses = 7)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    sessionParser = subparsers.add_parser("session")
    sessionParser.set_defaults(func=session_GLM)
    sessionParser.add_argument(
        "--workingDir",
        default=".",
        help="Working directory containing template fsf files",
    )

    args = parser.parse_args(["session"])
    logger.debug(f"Parsed: {args}")
    GLM_CLI(args)
