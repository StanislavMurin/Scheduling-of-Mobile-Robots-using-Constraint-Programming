/*
Copyright 2019 Murín Stanislav

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License.
*/

using CP;

tuple Triplet { // used for distance matrix
	int id1;
	int id2;
	int distance;
}

tuple Index {
	int j; // job
	int o; // operation
}

tuple Operation {
	int machine;
	int processingTime;
	int processingRequired;
}

// -----
// INPUT

int numOfMachines = ...;
int numOfRobots = ...;
int numOfJobs = ...;
int maxOperations = ...; // max of operation count among all jobs
int numOfActivities = 0;

range rMachines = 1..numOfMachines; // only processing machines
range rAllMachines = 0..numOfMachines; // includes L/U station indexex by 0
range rRobots = 1..numOfRobots;
range rJobs = 1..numOfJobs;
range rOperations = 1..maxOperations;

{Triplet} distanceMatrix;
int operationsCount[j in 1..numOfJobs] = ...; // operation count among jobs
Operation operation[1..numOfJobs][0..maxOperations] = ...; // information about specific operation, see Operation tuple
int travelTimes[0..numOfMachines][0..numOfMachines]=...; // travel time matrix, first index = from, second index = to

{Index} rActivity; // index set, ACTIVITY is index based on jobs and their operations

// -------------
// PREPROCESSING

int processingMachineType[rActivity]; // machine type (location) for every processing activity, used in noOverlap constraint with traveling matrix
int transportMachineType[rActivity]; // machine type (location) for every transport activity

int processingSize[rActivity]; // processing duration (interval size)
int transportSize[rActivity]; // transportation duration (interval size)

string sMachine1="";
string sMachine2 = "";
execute{
	// calculation of the total number of activities
	var i;
	for(i in rJobs){
		numOfActivities = numOfActivities + operationsCount[i];	
	}

	//Initializing set of indices
	 var jj, oo;
	 for(jj in rJobs){
	 	for(oo in rOperations){
	 		if(oo > operationsCount[jj]) continue;
	 		rActivity.add(jj, oo);	 	
	 	}	 
	 }

	// calculation of distance matrix
	var k,l,m,n,distance;
	for(m in rAllMachines){
		for(n in rAllMachines){
			for(k in rAllMachines){
				for(l in rAllMachines){
					distance = travelTimes[n][k];
					sMachine1 = ""+m+n;
					sMachine2 = ""+k+l;	
					distanceMatrix.add(sMachine1, sMachine2, distance);	
 				}
			} 						
		}	
	}
	// calculation of machine types and interval sizes 
	var a,t;
	for(a in rActivity){
		processingSize[a] = operation[a.j][a.o].processingTime;
		transportSize[a] = travelTimes[operation[a.j][a.o-1].machine][operation[a.j][a.o].machine];	
		
		transportMachineType[a] = ""+operation[a.j][a.o-1].machine+operation[a.j][a.o].machine; 		 	
		processingMachineType[a] = ""+operation[a.j][a.o].machine+operation[a.j][a.o].machine;
	}
}

// ----------------
// DOMAIN VARIABLES 

// processing and transport interval variables for jobs and their operations
dvar interval processing[a in rActivity] size processingSize[a];
dvar interval transport[a in rActivity] size transportSize[a];

// duplicate intervals for every robot, optional for use in alternative constraint
dvar interval rbtProcessing[rRobots][a in rActivity] optional size processingSize[a];
dvar interval rbtTransport[rRobots][a in rActivity] optional size transportSize[a];

// sequence of activities each robot carries out, append joins transportations and processings
dvar sequence rbtRoute[r in rRobots] 
	in  append(all(a in rActivity) rbtProcessing[r][a], all(a in rActivity) rbtTransport[r][a]) 
	types append(all(a in rActivity) processingMachineType[a], all(a in rActivity) transportMachineType[a]); 
		
// sequence of processings done on each machine
dvar sequence machinePlan[m in rMachines] in all(a in rActivity: operation[a.j][a.o].machine == m) processing[a];

// ------------------
// OBJECTIVE FUNCTION

// we want last PROCESSING activity to end as soon as possible
minimize max(a in rActivity: a.o == operationsCount[a.j]) endOf(processing[a]);

// -----------
// CONSTRAINTS

subject to{

	forall(a in rActivity){	
		forall(r in rRobots){
			if(operation[a.j][a.o].processingRequired == 0) {
				// remove ROBOT PROCESSING where no processing is to happen => others must remain OPTIONAL(for alternative constraint to work)			
				presenceOf(rbtProcessing[r][a])==0;				
			}	
		}					
	}
		
	// operations of one robot cannot overlap - also traveling times must be incured between operations (distance matrix)
	forall(r in rRobots){
		noOverlap(rbtRoute[r],distanceMatrix);	
	}
	
	// processings done on machine cannot overlap
	forall(m in rMachines){
		noOverlap(machinePlan[m]);	
	}
	
	forall(a in rActivity){	
		// operation has to be delivered to machine before it can be processed there
		endBeforeStart(transport[a],processing[a]);	
	}
	forall(a in rActivity: a.o != 1){ // no PROCESSING happens at L/U station, therefore cannot be bound to first TRANSPORT, we skip first index
		// operation can only be picked up from machine after it has been processed there
		endBeforeStart(processing[prev(rActivity,a)],transport[a]);
	}
	
	forall(a in rActivity){
		// only one robot can do any activity's TRANSPORT	
		alternative(transport[a], all(r in rRobots) rbtTransport[r][a]);	
		// only one robot can do the PROCESSING of activity - and only if it is required
		if(operation[a.j][a.o].processingRequired == 1){	
			alternative(processing[a], all(r in rRobots) rbtProcessing[r][a]);
		}
	}
}