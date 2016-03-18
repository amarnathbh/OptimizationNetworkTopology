
param D  > 0 integer;
param E  > 0 integer;
param N  > 0 integer;
param Pd > 0 integer;
#//#############################################################
set Nodes       := 1..N;
set link_nos    := 1..E;
set demand_nos  := 1..D;
set route_nos   := 1..Pd;

#Generation of links
param link_src {link_nos} within Nodes;
param link_dest {link_nos} within Nodes;
param link_capacity {link_nos} >= 0 integer;
param link_cost {link_nos} >= 0 integer;

#Generation of Demands
param demand_src {demand_nos} within Nodes;
param demand_dest {demand_nos} within Nodes;

#Generation of Routes
set Routes{demand_nos,route_nos} within link_nos;

param h {demand_nos} >= 0 integer;
##################################################################
#Generation of the variables required for optimization formulation
##################################################################
param delta {e in link_nos, d in demand_nos, p in route_nos}
        = if e in Routes[d,p] then 1 else 0;
##################################################################
#Variables for the problem
##################################################################
var x {d in demand_nos, p in route_nos} >= 0; 
##################################################################
var mul{e in link_nos}>=0 integer;
var y{e in link_nos}>=0;
var u{d in demand_nos, p in route_nos} binary;


#Objective function- Maximize the Throughput
####################################################################
minimize MinimizeCost:sum{e in link_nos} link_cost[e]*y[e];
####################################################################
#Constraints
####################################################################
subj to all_demands {d in demand_nos,p in route_nos}:
    x[d,p] = 3*h[d]*u[d,p];

subj to capacity_constraints {e in link_nos}:
    sum{d in demand_nos} ( sum{p in route_nos} (delta[e,d,p]*x[d,p]))
            - y[e]<= 0;
subj to modularity_contraints {e in link_nos}:
	0<=y[e]-link_capacity[e]<=0;

subj to binary_contraints {d in demand_nos}:
 		sum{p in route_nos} (u[d,p])=1;
###################################################################                                                                            
