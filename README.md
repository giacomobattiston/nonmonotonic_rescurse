# Index
- [Introduction](#technology_conflict)
- [Folder structure](#folder-structure)

# technology_conflict

Collaborators: Giacomo Battiston, Matteo Bizzarri and Riccardo Franceschin

Replication files for the paper "Third parties and the non-monotonicity of the resource curse: Evidence from US military influence and oil value"

## Folder structure

```stata
git/technology_conflict
├────README.md
│    
└────analysis
     ├──main.do
     └──gwno.do     


Dropbox/technology_conflict
│    ├──1_data /* raw data */
│    ├──2_processed /* processed (intermediate) data */
│    ├──3_temp /* temporary data */
│    ├──4_documentation
│    ├──5_output
|    ├──6_literature
└──main
````

The do-file main.do performs the whole analysis, and it calls the gwno.do to assign predetermined codes to countries.

The do file main.do  receives as input all of the raw datasets we use in our analysis, explained in the data appendix of the paper, and produces as output all of the tables and graphs included in the paper.

The first section in the paper (lines 1 to 14), assigns the right path for raw data and output folders based on the Stata user performing the analysis and adds an ado used to retrieve Stock and Yogo critical values in the IV estimation.

The second section of the do-file (lines 15 to 1666) prepares all of the data for the analysis.
It opens the raw datasets containing information on for oil prices, countries' UNGA voting affinity with the US, arms trade with the US and the USSR, US bases presence (merged with distance information), distance from the US, and arms trade.
Each of the previous is transformed into intermediate (processed) datasets.

In the third section of the do-file (lines 1666-2303), we prepare the final datasets used in the analysis.
We first open the dataset used by Hunziker and Cederman (2017); then, we merge it with data by Ashraf and Galor (2013), and with all of the intermediate datasets prepared in the second section.
Finally, we assign labels and save the final dataset.

In the fourth section of the do-file (lines 2303-10110), we produce all of the tables in the paper, preceded by a comment highlighting the table that is being produced.

In the fifth and last section (lines 10111-10178), we produce all of the figures shown in the paper, again in the same order as they appear and preceded by a comment reporting the reference in the paper.

