#!/usr/bin/python    
# Import the os module, for the os.walk function
import os
import argparse
import re
from shutil import copyfile

def getParameters():
    parser = argparse.ArgumentParser(description='Android Drawable Organiser. Organises Android drawable assets to drawable-<resolution> folders based on file name resolution suffixes (mdpi, hdpi, xhdpi, ...)')
    parser.add_argument('-i', '--input', help='Path to recursively look for resources', required = True)
    parser.add_argument('-o', '--output', help='Output folder for organised resources', required = True)
    results = parser.parse_args()
    return results

def getResources(resourcesPath):
    resourceList = []
    for dirName, subdirList, fileList in os.walk(resourcesPath):
        for fname in fileList:
            fullName = dirName + '/' + fname
            if isDrawable(fullName):
                resourceList.append(fullName)

    return resourceList

def isDrawable(resource):
    validExtentions = ('.png', '.avi')
    if resource.endswith(validExtentions):
        return True

    return False

def getDrawableResolution(fileName):
    resolutions = ['xxxhdpi', 'xxhdpi', 'xhdpi', 'hdpi', 'mdpi']

    for resolution in resolutions:
        if resolution in fileName:
            return resolution

    raise ValueError('Unable to find a resolutions for resource', fileName)


def prepareOutputFilename(fileName):
    srcFileName = os.path.basename(fileName)
    resolution = getDrawableResolution(fileName)

    dstFileName = srcFileName.replace(resolution, '')

    m = re.search("[a-zA-Z]", dstFileName)
    dstFileName = dstFileName[m.start():]
    dstFileName = dstFileName.replace(' ', '_').lower()


    #regex = re.compile('[^a-zA-Z.]')
    #dstFileName = regex.sub('', dstFileName).lower()

    return dstFileName

def getImageDetails(resources):
    imageDetails = []
    for fileName in resources:
        resolution = getDrawableResolution(fileName)
        outputFileName = prepareOutputFilename(fileName)

        imageDetail = {'fileName': fileName,
                       'outputFileName': outputFileName,
                       'resolution': resolution}
        imageDetails.append(imageDetail)

    return imageDetails

def copyFilesToDestination(imgDetails, outputDir):
    for imageDetail in imgDetails:
        outputFullFileName = outputDir + '/' + 'drawable-' + imageDetail['resolution'] + '/' + imageDetail['outputFileName']
        imageDetail['outputFullFileName'] = outputFullFileName

        destDir = os.path.dirname(imageDetail['outputFullFileName'])
        if not os.path.exists(destDir):
            os.makedirs(destDir)

        print(imageDetail['fileName'] + ' -> ' + imageDetail['outputFullFileName'])
        copyfile(imageDetail['fileName'], imageDetail['outputFullFileName'])
    return


parameters = getParameters()
rootDir = parameters.input
outputDir = parameters.output
print('Looking for resources: %s' % rootDir)
resources = getResources(rootDir)
imgDetails = getImageDetails(resources)
copyFilesToDestination(imgDetails, outputDir)
