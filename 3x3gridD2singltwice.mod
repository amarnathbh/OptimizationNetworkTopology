
param D  > 0 integer;
param E > 0 integer;
param N > 0 integer;
param Pd > 0 integer;
param S > 0 integer;
param Qe > 0 integer;

#//#############################################################
set Nodes       := 1..N;
set link_nos    := 1..E;
set demand_nos  := 1..D;
set route_nos   := 1..Pd;
set rest_paths	:=1..Qe;

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
set Routes_rest{link_nos,rest_paths} within link_nos;

param h {demand_nos} >= 0 integer;

#param dc{demand_nos, states}>=0 integer;
#param alpha{link_nos, states} binary;
#param theta{demand_nos, route_nos, states} binary;


##################################################################
#Generation of the variables required for optimization formulation
##################################################################
param delta {e in link_nos, d in demand_nos, p in route_nos}
        = if e in Routes[d,p] then 1 else 0;
param beta { l in link_nos, e in link_nos, q in rest_paths}
       = if e in Routes[e,q] then 1 else 0;
##################################################################
#Variables for the problem
##################################################################
var x {d in demand_nos, p in route_nos} >= 0; 
##################################################################
#var mul{e in link_nos}>=0 integer;
var y {e in link_nos}>=0 integer;
var z {e in link_nos, q in rest_paths}>=0;
var yd {l in link_nos}>=0;
var u{d in demand_nos, p in route_nos} binary;

#Objective function- Maximize the Throughput
####################################################################
minimize MinimizeCost:sum{e in link_nos}
					link_cost[e]*(y[e]+yd[e]);
####################################################################
#Constraints
####################################################################


subj to constraints {d in demand_nos,p in route_nos}:
      x[d,p]- 2*u[d,p]*h[d]= 0;
            
subj to capacity_constraints {e in link_nos}:
    sum{d in demand_nos} ( sum{p in route_nos} (delta[e,d,p]*x[d,p]))
            - 10*y[e]<= 0;
 
subj to normal_capacity_constraints {e in link_nos}:
    sum{q in rest_paths} z[e,q]-10*y[e]= 0;
            
subj to rest_capacity_contraints {l in link_nos, e in link_nos : l<>e}:
	sum{q in rest_paths} beta[l,e,q]*z[e,q]-yd[l]<=0;

subj to bin_contraints {d in demand_nos}:
 		sum{p in route_nos} (u[d,p])=1;



###################################################################                                                                            

