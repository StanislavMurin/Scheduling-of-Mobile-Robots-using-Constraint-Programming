/*
Copyright 2019 Murín Stanislav

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License.
*/

using CP;
main{
	var iterations = 2; //number of iterations
	var jobSet = 1; 
	var layout = 2;
	var searchType = "Auto"; // "Auto", "MultiPoint", "Restart", "DepthFirst"
	Opl.srand((new Date()).getMilliseconds()); //initialize seed for pseudo-random number generator 
	for(jobSet = 1; jobSet<=10; jobSet++){ 
		for(layout = 1; layout <= 4; layout++ ){	
			writeln(searchType);	
			writeln("CP|EX"+jobSet+""+layout);
			var i;
			for(i=1; i<=iterations;i++){	
				var seed = Opl.rand(201709013); //every iteration generate random seed for search
				
				// initialization of the solver
				var cp = new IloCP();
				var source = new IloOplModelSource("model.mod"); // "model_pickup_and_delivery.mod"
				var opl = new IloOplModel(new IloOplModelDefinition(source),cp);
				var dataJobSet = new IloOplDataSource("CP_data_40/JobSet"+jobSet+".dat");
				var dataLayout = new IloOplDataSource("CP_data_40/Layout"+layout+".dat");
				opl.addDataSource(dataJobSet);
				opl.addDataSource(dataLayout);
				opl.generate();
				
				// solver settings
				cp.param.LogVerbosity = "Quiet";
				cp.param.Workers = 1; //single thread
				cp.param.RandomSeed = seed;
				cp.param.SearchType = searchType;
				
				// run solver with solve method. If successful ,output iteration, objective value, seed and time spent in solver 
				if(cp.solve()){	
					writeln(""+i+"|"+cp.getObjValue()+"|"+seed+"|"+cp.info.SolveTime);	
					
				}
				
				//close opened objects
				var modelDefinition = opl.modelDefinition;
				opl.end();
				modelDefinition.end();
				cp.clearModel();
				cp.end();
				dataJobSet.end();
				dataLayout.end();
				source.end();	
 			}	
		}	
	}	
}