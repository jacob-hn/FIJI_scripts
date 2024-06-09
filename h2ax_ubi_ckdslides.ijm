// Define directory:
dir_path = "/Volumes/dfs/Nat_CDlab/Personal folders/JN/IF images CKD H2Ax plus ubi (stacks)/circTULP4/2022-12-19/analysis/with_ubi";
dir_path = dir_path + "/"

// List all files in the directory:
list = getFileList(dir_path);


// Process each .czi file:
for (i=0; i<list.length; i++) {
    if (endsWith(list[i], ".czi")) {
        // Get prefix from file name:
        prefix = replace(list[i], ".czi", "");
        suffix = ".czi";
        file_name = prefix + suffix;
        full_path = dir_path + file_name;

        // Open file:
        open(full_path);
        
        // Z-project
        run("Z Project...", "projection=[Max Intensity]");

 		run("Duplicate...", "title=Z-project duplicate");
    	selectWindow("Z-project");
        
        Stack.setChannel(3); // Assuming DAPI/Hoechst is the third channel
        setSlice(3); 
        run("Duplicate...", "title=nuclei");
       
        // set threshold
        run("8-bit");
        setAutoThreshold("Default"); 
        //setThreshold(0, 45); 
        
        setOption("BlackBackground", true);

        // Create a binary mask
        selectWindow("nuclei"); 
        run("Create Mask");  
        run("Invert");
        run("Fill Holes"); 
        run("Watershed");
      
        
        // Create a selection of the nuclei
        run("Create Selection");
        roiManager("add");
            
        // Analyze particles directly on the "nuclei" channel
        selectWindow("mask"); 
        run("Set Measurements...", "area shape mean");
        run("Analyze Particles...", "size=2000-Infinity pixel show=Outlines");
        
        // Save results
        saveAs("Results", dir_path + prefix + "_nuclei_count_RESULTS.csv");
        
        
        // Switch to channel with nuclear protein of interest 
        selectWindow("Z-project");
        Stack.setChannel(2); // Assuming POI is in the second channel
        setSlice(2); 
        run("Duplicate...", "title=h2ax");
        
        run("Grays");
        run("Enhance Contrast...", "saturated=0.10");
        
        // Analyze h2ax nuclear stain using nuclear mask
        selectWindow("mask");
		run("Set Measurements...", "area mean min perimeter fit shape feret's integrated median display redirect=h2ax decimal=4");
		run("Analyze Particles...", "size=2000-Infinity pixel show=Outlines");
		
		// Save h2ax results
		saveAs("Results", dir_path + prefix + "_h2ax_stain_RESULTS.csv");
        
        
        
        // Switch to channel with nuclear protein for control
        selectWindow("Z-project");
        Stack.setChannel(1); // Assuming control is in the first channel
        setSlice(1); 
        run("Duplicate...", "title=ubi");
        
        run("Grays");
        run("Enhance Contrast...", "saturated=0.10");
        
        // Analyze ubiquitin nuclear stain using nuclear mask
        selectWindow("mask");
		run("Set Measurements...", "area mean min perimeter fit shape feret's integrated median display redirect=ubi decimal=4");
		run("Analyze Particles...", "size=2000-Infinity pixel show=Outlines");
		
		// Save ubiquitin results
		saveAs("Results", dir_path + prefix + "_ubi_stain_RESULTS.csv");
        
        roiManager("delete");
        run("Clear Results");
        
        // Close all windows:
        run("Close All");
        
        /*  
         *   
     */   
    	
        
    }  
} 


