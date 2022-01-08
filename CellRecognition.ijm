
#@ File (label="Select a file") input
// need to set bio-image as windowless
//need to instal stardist
//need to set the stardist package
//need to install excel read and write
open(input);

run("Split Channels");
title = getTitle();

list = getList("image.titles");
  if (list.length==0)
     print("No image windows are open");
  else {
     for (i=0; i<list.length; i++) { // deletes unused channels
     	selectWindow(""+list[i]+"");
     	title = getTitle();
     	if  (indexOf(title, "C1") >= 0) {
     		run("Z Project...", "projection=[Average Intensity]"); //Z project of C1 layer
     	} else if (indexOf(title, "C3") >= 0) {
     		run("Z Project...", "projection=[Average Intensity]");// Z project of C3 layer
     	} else {
         close();
     	}
     }
  }

 
list = getList("image.titles");
 if (list.length==0)
     print("No image windows are open");
  else {
     for (i=0; i<list.length; i++) {
     	selectWindow(""+list[i]+"");
     	title = getTitle();
     	if  (indexOf(title, "AVG_C1") >= 0) { // selecting C1 window 
     		selectedWindow = title;
     	} else {
     		selectedWindowRed = title; // selecting C2 window
     	}
     }
  }
  
run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input': '"+selectedWindow+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'3.3', 'percentileTop':'98.30000000000001', 'probThresh':'0.8', 'nmsThresh':'0.15000000000000002', 'outputType':'ROI Manager', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");

    // iterating over all ROIs, creates an integrated profile along an imageaxis for all roi

    function rectSelectRoi()
        // creates a rectangular selection around the roi
    {
        var xmin, ymin, xmax, ymax, xmean, ymean, xstdDev, ystdDev, profile;

        // get roi vector points, where Roi is built-in object, referencint ot the current
        // selected roi
        Roi.getCoordinates(xpoints, ypoints);
        Array.getStatistics(xpoints, xmin, xmax, xmean, xstdDev);
        Array.getStatistics(ypoints, ymin, ymax, ymean, ystdDev);
        
        makeLine(xmin, ymin, xmax, ymax);
    }


    function dmpRoiProfile(roiIdx, profileRed, profileBlue )
    {
         for (i=0; i<profileRed.length; i++) {
     	
     		 	setResult(roiIdx + "B", i, profileBlue[i]); //writes blue profile first
     			setResult(roiIdx + "R", i, profileRed[i]); //writes red profile second
     		 	updateResults;
     		 }
  				
         }

    var roiCount = roiManager("count");
    Table.create("Results");
    for ( var roiIdx = 0; roiIdx < roiCount; ++roiIdx )
    {
        roiManager("select", roiIdx);
        rectSelectRoi();
        profileRed = getProfile();
        selectWindow(selectedWindow);
        roiManager("select", roiIdx);
        rectSelectRoi();
        profileBlue = getProfile();
        dmpRoiProfile(roiIdx, profileRed, profileBlue);

    }
	selectWindow("Results");
	run("Read and Write Excel");
	close("*"); // close all images and tabs and prepare for the next run
	close("Results");
	close("ROI Manager");
	close("Console");