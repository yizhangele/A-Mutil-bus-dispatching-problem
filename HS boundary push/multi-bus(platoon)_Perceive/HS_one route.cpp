// HS_one route.cpp : Defines the entry point for the console application.
// to make consistent with the MILP, B_b,i,j(k) can also be considered as decision variables, like x_b(k) and Q_b,i(k)

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <algorithm>
#include "stdafx.h"

#include<sys/types.h>
#include <time.h>
#include <iostream>
#include <fstream>
#include "string.h"

#define square(x) ((x)*(x))
#define maxpop 500  /*Max population */ // >popsize 
const int Gen = 1000; // running times
const int MaxBusStopNum=30;// max row number 30
const int MaxBusNum=20;// max column number 20
const int MaxTimeInt=30; // max prediction horizon 30
const int popsize = 50;  /*Population Size*/ 
const int parent_num = 50;

using namespace std;
ofstream outfile;
FILE *fp;
errno_t err;


// incoming passenger flow for each bus stop
int FlowIn[MaxTimeInt][MaxBusStopNum][MaxBusStopNum];

double VolumeProportion1[MaxTimeInt][MaxBusStopNum]; //= {1, 5, 3, 15, 17, 25, 2, 3, 9, 8, 32, 1, 2, 40, 3};
//int VolumeProportion2[TripNum][StopNum];// = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
double DestinationProportion1[MaxTimeInt][MaxBusStopNum][MaxBusStopNum];
int Passenger_come;

// volume in buses

/*Chromosome Size*/
static int BusNum = 5;         
static int BusStopNum =10; 
static int Num_Int =12; 
static int returnHorizon =6;

typedef struct       /*individual properties*/ 
{
  int genes_stop[MaxTimeInt][MaxBusNum][MaxBusStopNum], /*bianry chromosome*/
      genes_dispatch[MaxTimeInt][MaxBusNum]; /*bianry chromosome*/

 int fitness; /*Fitness values */ // fitness[0] = delay, fitness[1] = unhappiness
 int space;
 int delay;
 
 //int boardvolume[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 
 //int busvolume[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 

 int DataLoadTime[MaxTimeInt][MaxBusNum][MaxBusStopNum]; // loading time for bus b of trip k at stop i
 int DataTrueDwellTime[MaxTimeInt][MaxBusStopNum];       // maximum loading time for buses of trip k <= DwellTime (180s in fitness.h): fixed stopping time of buses of trip k at stop i 
}individual;        /*Structure defining individual*/


typedef struct
{
  individual ind[maxpop], /*Different Individuals*/
    *ind_ptr; 
}population ;             /*Popuation Structure*/

int iteration[Gen][3];

#include "init.h"         /*Random Initialization of the population*/
//
#include "sorting.h"      /*File Creating the Pareto Fronts*/
//
#include "fitness.h"     /*File Having the Function*/
//
//#include "select.h"       /*File for Tournament Selection*/
//
#include "GenNewHarmony.h"    /*Binary Cross-over*/
//

//
//#include "replacement.h"   /*File For Elitism and Sharing Scheme*/
using namespace std;

population 
	old_pop,
	new_pop,
	parent_pop,
	new2_pop,
  *old_pop_ptr,
  *new_pop_ptr,
  *parent_ptr,
  *new2_pop_ptr;
/*Defining the population Structures*/

void Generate_Passenger_Instance()
{
	int i,l,r;
	
	outfile.open("Instance.csv",ios::app);
			for(l=0;l<BusStopNum;l++)
			{
				/*if(l==0)
				{
					for(i=l+1;i<(BusStopNum);i++)
				   {	
					   if( (i==2)|(i==4)|(i==6)|(i==9) )
							r= 25+rand()%10;
					   if( (i==1)|(i==8) )
						   r = 5+rand()%10;
					   if( (i==3)|(i==5)|(i==7) )
						   r=0;

						outfile<<r<<" ";				
				   }
				  outfile<<endl;
				}
				else
				{
					for(i=l+1;i<(BusStopNum+1);i++)
				   {	
					   if( (i==2)|(i==4)|(i==6)|(i==9) )
							r= 25+rand()%10;
					   if( (i==1)|(i==8) )
						   r = 5+rand()%10;
					   if( (i==3)|(i==5)|(i==7) )
						   r=0;
					   if(i==10)
						   r=20+rand()%10;

						outfile<<r<<" ";				
				   }
				  outfile<<endl;
				}*/
				if(l==0)
				{
					for(i=l+1;i<(BusStopNum);i++)
				   {						
						r= rand()%20;
						outfile<<r<<" ";				
				   }
				  outfile<<endl;
				}
				else
				{
					for(i=l+1;i<(BusStopNum+1);i++)
				   {						
						r= rand()%20;
						outfile<<r<<" ";				
				   }
				  outfile<<endl;
				}
			}
	outfile<<"/////////////////////////////////////"<<endl;
	outfile.close();
}

void Read_Passenger_Instance()
{

	//fp = fopen("Instance.csv","r");
	//if(fp == NULL)
	//{
	//	printf("\nThere is no Proportion file or no data in destination_proportion2\n");
	//	system("pause");	
	//}
	// 
	//
	//	for(int j=0;j<StopNum;j++)
	//	{
	//		for(int i=0;i<StopNum;i++)
	//		{
	//         fscanf(fp,"%d",&PassStop[0][j][i]);
	//		}
	//	}
	//	fclose(fp);
int Volume_Instance[MaxBusNum*MaxBusNum] = {};
int count=0;

if ((err = fopen_s(&fp, "Instance.csv", "r")) != 0)
    printf("\nThere is no Instance file or no data in Instance\n");
else
{
			for(int i=0;i<BusStopNum;i++)
		   {
			   if(i==0)
				{
					for(int j=i+1;j<BusStopNum;j++)
					{
					  //int file_input;
					  fscanf_s(fp, "%d",&StopVolume[0][i][j]);
					  Volume_Instance[count] = StopVolume[0][i][j];
					  count=count+1;
					  //printf("%d\n", PassStop[0][j][i]);
					}
			   }
			   else
			   {
				   for(int j=i+1;j<(BusStopNum+1);j++)
					{
					  //int file_input;
					  fscanf(fp, "%d",&StopVolume[0][i][j]);
					  Volume_Instance[count] = StopVolume[0][i][j];
					  count=count+1;
					  //printf("%d\n", PassStop[0][j][i]);
					}
			   }
			}
		    
}
fclose(fp);

// Instance for matlab
	outfile.open("Instance_matlab.csv",ios::app);
	for(int l=0;l<count;l++)
	{			
		outfile<<Volume_Instance[l]<<endl;				
	}
		outfile.close();
		
}

void Generate_Proportions()
{
	int i,j,k,l,r;
	
	outfile.open("Proportion1.csv",ios::app);
	for(k=0;k<Num_Int;k++)
		{
				/*for(l=0;l<(BusStopNum);l++)
				{	
					if( (l==0)|(l==2)|(l==4)|(l==6))
						r = 5;
					else
						r = 1;
					outfile<<r<<" ";
				}
				outfile<<endl;*/
				for(l=0;l<BusStopNum;l++) 
				{
						r=rand()%50;
					    outfile<<r<<" ";
				}
				outfile<<endl;
		   }
	outfile<<"/////////////////////////////////////"<<endl;
	outfile.close();
	// averagely distributed
	//outfile.open("Proportion2.csv",ios::app);
	//	for(k=0;k<TripNum;k++)
	//	{
	//			for(l=0;l<StopNum;l++)
	//			{
	//				r=1;
	//				outfile<<r<<" ";
	//			}
	//			outfile<<endl;
	//	   }
	//outfile<<"/////////////////////////////////////"<<endl;
	//outfile.close();

	outfile.open("destination_proportion1.csv",ios::app);
	for(k=0;k<Num_Int;k++)
	{
			/*for(l=0;l<BusStopNum;l++)
			{
				if(l==0)
				{
					for(i=l+1;i<(BusStopNum);i++)
				   {	
					   if( (i==2)|(i==4)|(i==6)|(i==9) )
							r= 5;
					   if( (i==1)|(i==8) )
						   r = 1;
					   if( (i==3)|(i==5)|(i==7) )
						   r=0;

						outfile<<r<<" ";				
				   }
				  outfile<<endl;
				}
				else
				{
					for(i=l+1;i<(BusStopNum+1);i++)
				   {	
					   if( (i==2)|(i==4)|(i==6)|(i==9) )
							r= 5;
					   if( (i==1)|(i==8) )
						   r = 1;
					   if( (i==3)|(i==5)|(i==7) )
						   r=0;
					   if(i==10)
						   r=4;

						outfile<<r<<" ";				
				   }
				  outfile<<endl;
				}*/
		for(l=0;l<BusStopNum;l++)
			{
				if(l==0)
				{
					for(i=l+1;i<BusStopNum;i++)
					{						
							r= rand()%10;
							outfile<<r<<" ";				
					}
					outfile<<endl;
				}
				else
				{
						for(i=l+1;i<(BusStopNum+1);i++)
						{						
								r= rand()%10;
								outfile<<r<<" ";				
						}
						outfile<<endl;
				}
			}
			outfile<<endl;
		}
	outfile<<"/////////////////////////////////////"<<endl;
	outfile.close();
	// // averagely distributed
	//outfile.open("destination_proportion2.csv",ios::app);
	//for(k=0;k<TripNum;k++)
	//{
	//		for(l=0;l<StopNum;l++)
	//		{
	//			for(i=0;i<StopNum;i++)
	//			{						
	//					r= 1;
	//					if(i==l)
	//					r=0;
	//					if((l>1) && (i<l)&&(i!=0))
	//					{
	//						r=0;
	//					}
	//					outfile<<r<<" ";				
	//			}
	//			outfile<<r<<endl;
	//		}
	//		outfile<<endl;
	//	}
	//outfile<<"/////////////////////////////////////"<<endl;
	//outfile.close();
}
   //int desPro1[TripNum*StopNum*StopNum]={};
   //int desPro2[TripNum*StopNum*StopNum]={};
void Read_Proportions()
{
   int i,j,k,l;

	string str;
	//fp = fopen("Proportion1.csv","r");
	//if(fp == NULL)
	//{
	//	printf("\nThere is no Proportion file or no data in Proportion1\n");
	//	system("pause");	
	//}
	//for(i=0;i<TripNum;i++)
	//	{
	//		for(j=0;j<StopNum;j++)
	//         {
	//			 fscanf(fp,"%d",&VolumeProportion1[i][j]);
	//         }
 //        }
	//fclose(fp);
if ((err = fopen_s(&fp, "Proportion1.csv", "r")) != 0)
    printf("\nThere is no Proportion file or no data in Proportion1\n");
else
{
			for(int j=0;j<Num_Int;j++)
		   {
				for(int i=0;i<BusStopNum;i++)
				{
				  //int file_input;
				  fscanf(fp, "%lf",&VolumeProportion1[j][i]);
				 // printf("%d\n", VolumeProportion1[j][i]);
				}
			}
		    
}
fclose(fp);

	//fp = fopen("Proportion2.csv","r");
	//if(fp == NULL)
	//{
	//	printf("\nThere is no Proportion file or no data in Proportion2\n");
	//	system("pause");	
	//}
	//	for(i=0;i<TripNum;i++)
	//	{
	//		for(j=0;j<StopNum;j++)
	//         {fscanf(fp,"%d",&VolumeProportion2[i][j]);
	//         }
 //        }
	//fclose(fp);

	//fp = fopen("destination_proportion1.csv","r");
	//if(fp == NULL)
	//{
	//	printf("\nThere is no Proportion file or no data in destination_proportion1\n");
	//	system("pause");	
	//}
	//	for(k=0;k<TripNum;k++)
	//	{
	//		for(l=0;l<StopNum;l++)
	//		{
	//			for(i=0;i<StopNum;i++)
	//			{
	//				fscanf(fp,"%d",&DestinationProportion1[k][l][i]); 
	//			}
	//		}
	//	}
	//fclose(fp);
	if ((err = fopen_s(&fp, "destination_proportion1.csv", "r")) != 0)
    printf("\nThere is no destination Proportion file or no data in destination_proportion1.csv\n");
else
{      for(k=0;k<Num_Int;k++)
		{
			for(int j=0;j<BusStopNum;j++)
		   {
				if(j==0)
				{
				   for(int i=j+1;i<BusStopNum;i++)
					{
				  
					  fscanf(fp, "%lf",&DestinationProportion1[k][j][i]);
					  //printf("%d\n", DestinationProportion1[k][j][i]);
					}
				}
				else
				{
				    for(int i=j+1;i<(BusStopNum+1);i++)
					{
				  
					  fscanf(fp, "%lf",&DestinationProportion1[k][j][i]);
					  //printf("%d\n", DestinationProportion1[k][j][i]);
					}
				}
			}
	}
		    
}
fclose(fp);
	//fp = fopen("destination_proportion2.csv","r");
	//if(fp == NULL)
	//{
	//	printf("\nThere is no Proportion file or no data in destination_proportion2\n");
	//	system("pause");	
	//}
	//for(i=0;i<TripNum*StopNum*StopNum;i++)
	//{fscanf(fp,"%d",&desPro1[i]); }
	//fclose(fp);

}


void system_initialization()
{   
	int Volume_FlowIn[MaxTimeInt*MaxBusNum*MaxBusNum] = {};
    int count=0;

	double TotalProportion1[MaxTimeInt] ={};
	//int TotalProportion2[TripNum] ={};
	double TotalDesProportion1[MaxTimeInt][MaxBusStopNum] = {};
	for(int k=0;k<Num_Int;k++)
	{	
		for(int i=0;i<BusStopNum;i++)
		{
			TotalProportion1[k]= TotalProportion1[k] +VolumeProportion1[k][i];
			//TotalProportion2[k]= TotalProportion2[k] +VolumeProportion2[k][i];
			if(i==0)
			{
				for(int j=i+1;j<BusStopNum;j++)
				{
					TotalDesProportion1[k][i] = TotalDesProportion1[k][i]+DestinationProportion1[k][i][j];
				}
			}
			else
			{
				for(int j=i+1;j<(BusStopNum+1);j++)
				{
					TotalDesProportion1[k][i] = TotalDesProportion1[k][i]+DestinationProportion1[k][i][j];
				}
			}
		}
	}

	for(int k=0;k<Num_Int;k++)
	{
	   for(int i=0;i<BusStopNum;i++)
		{
			if(i==0)
			{
				for(int j=i+1;j<BusStopNum;j++)
				{
					if((TotalProportion1[k] ==0) || (TotalDesProportion1[k][i]==0))
						FlowIn[k][i][j]=0;
					else
						FlowIn[k][i][j]=(VolumeProportion1[k][i]/TotalProportion1[k])*(DestinationProportion1[k][i][j]/TotalDesProportion1[k][i])*Passenger_come;

					Volume_FlowIn[count] = FlowIn[k][i][j];
					count=count+1;
				}
			}
			else
			{
				for(int j=i+1;j<(BusStopNum+1);j++)
				{
					if((TotalProportion1[k] ==0) || (TotalDesProportion1[k][i]==0))
						FlowIn[k][i][j]=0;
					else
						FlowIn[k][i][j]=(VolumeProportion1[k][i]/TotalProportion1[k])*(DestinationProportion1[k][i][j]/TotalDesProportion1[k][i])*Passenger_come;

					Volume_FlowIn[count] = FlowIn[k][i][j];
					count=count+1;
				}
			}

	    }
	}
	// output the final value
	outfile.open("FlowIn_matlab.csv",ios::app);
	int k;
	for(k=0;k<count;k++)
	{
		outfile<<Volume_FlowIn[k]<<endl;				
	}
	outfile.close();
		    
}
//void system_initialization()
//{
//	int i,j,k;
//	// stop volume initialization
// 	for(i=0; i< BusStopNum; i++)
//	{
//		if(i==0)
//		{
//			for(j=0; j<BusStopNum; j++)
//			{
//				StopVolume[0][i][j] = 10;
//				StopVolume[0][i][j] = 10;
//			}
//		}
//		else
//		{
//			for(j=i+1; j<(BusStopNum+1); j++)
//			{
//				StopVolume[0][i][j] = 10;
//				StopVolume[0][i][j] = 10;
//			}
//		}
//	}
//   
//	// incoming flow from outside
//	for(k=0; k<Num_Int; k++)
//	{
//		for(i=0; i< BusStopNum; i++)
//		{
//			for(j=0; j<(BusStopNum+1); j++)
//			{
//				FlowIn[k][i][j] = 10;
//
//			}
//		}
//	}
//
//}
// multi-bus platoon dispatch
int main()
{
	srand((unsigned) time(NULL)+ MaxBusNum* MaxBusStopNum*1000000);
	int k, b, i,j,l;
	Passenger_come = 3000;
	//Generate_Passenger_Instance();
	Read_Passenger_Instance();
	//Generate_Proportions();
	Read_Proportions();
	system_initialization();
	old_pop_ptr = &(old_pop);
   /*Signal Initializaton*/
  init(old_pop_ptr);  
   /*Fitness Evaluation*/
  fitness_cost(old_pop_ptr, 1); 
 // sorting(old_pop_ptr, popsize, 1);

  time_t start=clock();
  /********************************************************************/
  /*----------------------GENERATION STARTS HERE----------------------*/
  for (l = 0;l < Gen;l++)
    {
	  // parent_ptr = &(parent_pop);
      /*--------SELECT----------------*/
     // select(old_pop_ptr, parent_ptr, parent_num);
      
	  new_pop_ptr = &(new_pop);
      /*CROSSOVER----------------------------MUTATION*/      
	  Gene_New_Harmony(new_pop_ptr, old_pop_ptr);        
      /*----------FUNCTION EVALUATION-----------*/
      fitness_cost(old_pop_ptr, 2);
      sorting(old_pop_ptr, popsize, 2);
	  /* record every iteration's fitness, passenger delay and bus vacancy */
	  iteration[l][0] = old_pop_ptr->ind_ptr->fitness;
	  iteration[l][1] = old_pop_ptr->ind_ptr->delay;
	  iteration[l][2] = old_pop_ptr->ind_ptr->space;
  }
	time_t end=clock();
	outfile.open("CPU time.csv",ios::app); 
	outfile<<end-start<<endl;
	outfile.close();

   outfile.open("Bus results.csv",ios::app);
	for(i=0;i<Gen;i++)
	{ 		
		outfile<<iteration[i][0]<<" "<<iteration[i][1]<<" "<<iteration[i][2]<<endl;
	}
	outfile.close();
	
		 // outfile.open("Bus Dispatch results.csv",ios::app);
			//for(k=0;k<Num_Int;k++)
			//{ 	
			//	for(b=0;b<BusNum;b++)
			//	{
			//			outfile<<old_pop_ptr->ind_ptr->genes_dispatch[k][b]<<" ";
			//	}
			//	outfile<<endl;
		
			//}
			//outfile.close();

			//outfile.open("Bus Stop results.csv",ios::app);
			//for(k=0;k<Num_Int;k++)
			//{ 	
			//	for(b=0;b<BusNum;b++)
			//	{
			//		for(i=0;i<BusStopNum;i++)
			//		{
			//			outfile<<old_pop_ptr->ind_ptr->genes_stop[k][b][i]<<" ";
			//		}
			//		outfile<<endl;
			//	}
			//	outfile<<endl;
		
			//}
			//outfile.close();

			outfile.open("Load Time results.csv",ios::app);
			for(k=0;k<Num_Int;k++)
			{ 	
				for(b=0;b<BusNum;b++)
				{
					for(i=0;i<BusStopNum;i++)
					{
						outfile<<old_pop_ptr->ind_ptr->DataLoadTime[k][b][i]<<" ";
					}
					outfile<<endl;
				}
				outfile<<endl;
		
			}
			outfile.close();

			outfile.open("Dwell Time results.csv",ios::app);
			for(k=0;k<Num_Int;k++)
			{ 	
					for(i=0;i<BusStopNum;i++)
					{
						outfile<<old_pop_ptr->ind_ptr->DataTrueDwellTime[k][i]<<" ";
					}
					outfile<<endl;
		
			}
			outfile.close();
  return 0;
}



