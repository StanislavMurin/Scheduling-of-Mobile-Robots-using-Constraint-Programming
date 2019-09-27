This is source code for the paper 
Murín S., Rudová H. (2019) Scheduling of Mobile Robots Using Constraint Programming. In: Schiex T., de Givry S. (eds) Principles and Practice of Constraint Programming. CP 2019. Lecture Notes in Computer Science, vol 11802. Springer, Cham
Please cite this paper when using results of this work.

This README serves as a guide for running of our solver using IBM ILOG CPLEX Optimization Studio.
(In the project, the IBM ILOG CPLEX Optimization Studio 12.8 academic license was used.)

Installed and working version of Optimization Studio is required to run our models.

1. In the Optimization Studio File -> Import -> Existing OPL Project.
2. Navigate to the folder MobileRobots -> Check offered project -> Finish.
3. Inside the project, you can see folder Run Configurations. In this folder, there is a run configuration 'CP' for our CP model flow control named 'FlowControl_CP.mod'.
4. To run the model: right-click the 'CP' run configuration -> Run this (this run configuration allows to run one or mode data instances multiple times).
5. Run times will be logged to Scripting log on the lower tray. However, this run configuration does not display the values of decision variables in found solutions.
6. To run a single problem instance once (and be able to see values of decision variables in the solution) use run configuration 'CP_single' (you control the model and data files used by dragging and dropping them into the run configuration. Note that datafile for JobSet must be inserted before layout, see pre-prepared 'CP_single' run configuration).
7. After running the model, the optimal solution and values of decision variables can be seen in the lower-left corner in Problem Browser. In the right corner, there is interesting information about the computed solutions in the sheets 'Scripting log', 'Solutions', 'Engine log', 'Statistics', and 'Profiler'.