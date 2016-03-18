param S > 0 integer; #servive nodes
param C > 0 integer; # DC connection nodes
param V > 0 integer; # virtual nodes
param L > 0 integer; #Virtual links
param D > 0 integer; #demand
param El > 0 integer; # Endpoints of virtual link
param Z > 0 integer; # set of virtual link pairs
param E > 0 integer; # Edges in the pgysical network
param N > 0 integer; #Nodes in the physical network
param Pl > 0 integer; #set of physical edges on which virtual link is mapped
param R > 0; # DC connection node pair


set service_nodes := 1..S;
set dc_connect_nodes := 1..C;
set virtual_nodes := 1..V;
set virtual_links := 1..L;
set demand_nos := 1..D;
set virtual_links_end := 1..El;
set virtual_links_pair := 1..Z;
set link_nos := 1..E;
set Nodes := 1..N;
set vir_phy_link := 1..Pl;
set dc_connect_nodes_pair := 1..R;


#Generation of virtual links
param v_src {virtual_links} within Nodes;
param v_dest {virtual_links} within Nodes;


#Generation of demand


param src  {demand_nos} within Nodes;
param dest {demand_nos} within Nodes;


#Generation of Routes





#Parameters

param k=3;
param b {d in demand_nos} >= 0 integer;
param n {d in demand_nos}>= 0 integer;
param r {d in demand_nos}>= 0 integer;
param t {l in virtual_links} >= 0 integer; 
param lambda {l in virtual_links}>= 0 integer;
param theta {l in virtual_links}>= 0 integer;
param mu {v in virtual_nodes}>= 0 integer;
param eta {v in virtual_nodes}>= 0 integer;
param phi {c in dc_connect_nodes}>= 0 integer;
param psi {c in dc_connect_nodes}>= 0 integer;

var a {s in service_nodes, c in dc_connect_nodes} >=0 binary;


var temp {s in service_nodes, c in dc_connect_nodes, d in demand_nos, l in virtual_links} >=0 ;

var beta { d in demand_nos, l in virtual_links} binary;
var delta { d in demand_nos, v in virtual_nodes}  binary;
var gamma {l in virtual_links}  binary;
var alpha {v in virtual_nodes}  binary;
var y {c in dc_connect_nodes}  binary;
	
	
var u {l in virtual_links};
var w {v in virtual_nodes};
var z {c in dc_connect_nodes};






#Objective

minimize Cost: sum{l in virtual_links}((lambda[l]*gamma[l])+ (theta[l]*u[l]))
   + sum{v in virtual_nodes}((mu[v]*alpha[v])+ (eta[v]*w[v]))
   + sum{c in dc_connect_nodes}((phi[c]*y[c])+ (psi[c]*z[c]));
   
 
minimize Prop_Delay : sum {d in demand_nos} (sum {l in virtual_links} beta[d,l]*t[l]);  

#constraints

subj to server_selection {s in service_nodes} :
	sum {c in dc_connect_nodes} a[s,c] =k;
	

	
subj to link_flow {d in demand_nos,v in virtual_nodes,s in service_nodes,c in dc_connect_nodes}:
	sum { l in virtual_links : v in virtual_links_end} beta[d,l] 
	    = if (v=s ) then a[s,c]  else 2*delta[d,v]
	or
	 if (v=c) then a[s,c]  else 2*delta[d,v];
	 
subj to node_is_flagged_as_used {d in demand_nos, v in virtual_nodes,c in dc_connect_nodes,s in service_nodes} :
	delta[d,v]=a[s,c];		
	
subj to virtual_link_carrying_traffic {	l in virtual_links, d in demand_nos}:
	gamma[l] >= beta[d,l];

subj to virtual_node_carrying_traffic {v in virtual_nodes,d in demand_nos}:
	alpha[v] >=delta[d,v];
	
subj to virtual_machine_carrying_traffic { c in dc_connect_nodes,s in service_nodes}:
	y[c] >= a[s,c];

subj to upper_bound_virtual_links {l in virtual_links}:
	sum {d in demand_nos} beta[d,l] >= gamma[l];

subj to upper_bound_virtual_nodes {v in virtual_nodes}:
	sum {d in demand_nos} delta[d,v] >= alpha[v];
	
subj to upper_bound_virtual_machine {c in dc_connect_nodes}:
	sum {s in service_nodes} a[s,c] >= y[c];
	
subj to virtual_link_capacity {l in virtual_links}:
	sum {d in demand_nos} beta[d,l]*b[d] <=u[l];
	
subj to virtual_node_capacity {v in virtual_nodes}:
	sum {d in demand_nos} delta[d,v]*n[d] <=w[v];
	
subj to virtual_machine_capacity {c in dc_connect_nodes, d in demand_nos}:
	sum {s in service_nodes} a[s,c]*r[d] <=z[c];
	
# VNO resilience

subj to diversity_link { d in demand_nos,l in virtual_links}:
	
	beta[dem,l] + beta[dem,k] - 1 <= 0;
subj to diversity_node {d in demand_nos, v in virtual_nodes}:

	delta[dem,1] + delta[1,2] -2  <= 0;

subj to diversity_loc {s in service_nodes,c in dc_connect_nodes}:
    a[s,1] +a[s,2] + a[s,3] -3 <= 0;
     
	
			
			