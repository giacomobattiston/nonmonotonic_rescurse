# Index
- [Introduction](#technology_conflict)
- [Folder structure](#folder-structure)

# technology_conflict

Collaborators: Giacomo Battiston, Matteo Bizzarri and Riccardo Franceschin

Replication files for the paper "Third-Party Interest, Resource Value, and the Likelihood of Conflict"

## Folder structure

```stata
git/LEAPproject
├────README.md
│    
├────analysis
│    ├──main.do
│    │  ├──thirdparty.do
│    │  ├──gwno.do
│    ├──config.do     
└──config


Dropbox/LEAPproject
│    ├──1_data /* raw data */
│    ├──2_processed /* processed (intermediate) data */
│    ├──3_temp /* temporary data */
│    ├──4_documentation
│    ├──5_output
└──config

Overleaf/LEAPproject
│    ├──5_output
│    │  ├──tables
│    │  └──figures
│    │  └──statistics
└──config
````

Raw data lives in the data/ folder _(read-only)_ <br>
We do not version control data <br>
Scripts take us from raw data to analysis-ready data <br>

[Back to index](#index)
