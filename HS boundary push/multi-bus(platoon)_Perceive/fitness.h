/*This is the program used to evaluate the value of the function 
************************************************************************/

const int MaxBusSpace=100;

#define max(a,b) ((a>b)?a:b)
#define min(a,b) ((a>b)?b:a)
  
// Bus Volume of bus b in trip k when it approaching stop i with destination stop j
int BusVolume[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 

// Stop Volume at stop i when bus b of trip k is coming
int StopVolume[MaxTimeInt][MaxBusStopNum][MaxBusStopNum];

// Boarding Volume at stop i to bus b of trip k
int BoardVolume[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 
double BoardVolume_bus[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 
double BoardVolume_time[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 
double BoardVolume_stop[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 

// Total Volume in bus b of trip k when approaching stop j (do not include the alighting volume at stop j, \sum_{i}V[k][b][i][j] is not added in V[k][b][j])
int TotalBusVolume[MaxTimeInt][MaxBusNum][MaxBusStopNum];

// Total Boarding Volume of bus b in trip k at stop i 
int TotalBoardVolume[MaxTimeInt][MaxBusNum][MaxBusStopNum];

// incoming passenger flow for bus stop i with destination stop j when buses of trip k is coming
extern int FlowIn[MaxTimeInt][MaxBusStopNum][MaxBusStopNum];

// loading time for bus b of trip k at stop i 
int LoadTime[MaxTimeInt][MaxBusNum][MaxBusStopNum];
// true dwell time for buses in trip k at stop i
int TrueDwellTime[MaxTimeInt][MaxBusStopNum];
// parameters with boarding and alighting
#define BoardTime 2 // 2s per person
#define AlightTime 1.5
#define OpenTime 2
#define DwellTime 180 // 5 min

struct data{
	int delay;
	int space;
	int dataLoadTime[MaxTimeInt][MaxBusNum][MaxBusStopNum];
	int dataTrueDwellTime[MaxTimeInt][MaxBusStopNum];

	//int dataBusVolume[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum];
	//int dataBoardVolume[MaxTimeInt][MaxBusNum][MaxBusStopNum][MaxBusStopNum]; 
};

//double round(double d)
//{
//  return floor(d + 0.5);
//}

data Calculate_Bus_Cost( int (&BusDispatch)[MaxTimeInt][MaxBusNum], int (&BusStop)[MaxTimeInt][MaxBusNum][MaxBusStopNum])
{
	int i,j,k,b,r,m,n;
	int sum_b=0;
	int StopVeh[MaxTimeInt][MaxBusStopNum]={};
	int AlreadyBoardVolume[MaxTimeInt][MaxBusStopNum][MaxBusStopNum]={}; 
	int PassDelay=0, PassDelay2=0, BusVacancy=0;
	data returnvalue;
	double fraction_bus[MaxBusNum]={};
	double fraction_time[MaxBusStopNum]={};
	double fraction_stop[MaxBusStopNum]={};
	int sumboardtime=0;
	int sumalighttime=0;
	// for test: optimal result for MILP
	///*BusStop[0][0][0]=0;
	//BusStop[1][0][0]=1;
	//BusStop[2][0][0]=0;
	//BusStop[3][0][0]=1;

	//BusStop[0][1][0]=1;
	//BusStop[1][1][0]=0;
	//BusStop[2][1][0]=1;
	//BusStop[3][1][0]=0;
	//
	//BusStop[0][2][0]=0;
	//BusStop[1][2][0]=1;
	//BusStop[2][2][0]=0;
	//BusStop[3][2][0]=1;

	//BusStop[0][0][1]=0;
	//BusStop[1][0][1]=1;
	//BusStop[2][0][1]=0;
	//BusStop[3][0][1]=0;
	//BusStop[4][0][1]=1;

	//BusStop[0][1][1]=1;
	//BusStop[1][1][1]=0;
	//BusStop[2][1][1]=1;
	//BusStop[3][1][1]=0;

	//BusStop[0][2][1]=0;
	//BusStop[1][2][1]=1;
	//BusStop[2][2][1]=0;
	//BusStop[3][2][1]=1;

	//BusStop[0][0][2]=0;
	//BusStop[1][0][2]=1;
	//BusStop[2][0][2]=0;
	//BusStop[3][0][2]=1;

	//BusStop[0][1][2]=1;
	//BusStop[1][1][2]=0;
	//BusStop[2][1][2]=1;
	//BusStop[3][1][2]=0;

	//BusStop[0][2][2]=0;
	//BusStop[1][2][2]=1;
	//BusStop[2][2][2]=0;
	//BusStop[3][2][2]=1;

	//BusStop[0][0][3]=0;
	//BusStop[1][0][3]=1;
	//BusStop[2][0][3]=0;
	//BusStop[3][0][3]=1;

	//BusStop[0][1][3]=1;
	//BusStop[1][1][3]=0;
	//BusStop[2][1][3]=1;
	//BusStop[3][1][3]=0;

	//BusStop[0][2][3]=0;
	//BusStop[1][2][3]=1;
	//BusStop[2][2][3]=0;
	//BusStop[3][2][3]=1;

	//BusStop[0][0][4]=0;
	//BusStop[1][0][4]=1;
	//BusStop[2][0][4]=0;
	//BusStop[3][0][4]=1;

	//BusStop[0][1][4]=1;
	//BusStop[1][1][4]=0;
	//BusStop[2][1][4]=1;
	//BusStop[3][1][4]=0;

	//BusStop[0][2][4]=0;
	//BusStop[1][2][4]=1;
	//BusStop[2][2][4]=0;
	//BusStop[3][2][4]=1;

	//BusStop[0][0][5]=1;
	//BusStop[1][0][5]=0;
	//BusStop[2][0][5]=0;
	//BusStop[3][0][5]=0;
	//BusStop[4][0][5]=1;

	//BusStop[0][1][5]=1;
	//BusStop[1][1][5]=0;
	//BusStop[2][1][5]=0;
	//BusStop[3][1][5]=0;
	//BusStop[4][1][5]=1;

	//BusStop[0][2][5]=0;
	//BusStop[1][2][5]=1;
	//BusStop[2][2][5]=0;
	//BusStop[3][2][5]=0;
	//BusStop[4][2][5]=0;

	//BusStop[0][0][6]=1;
	//BusStop[1][0][6]=0;
	//BusStop[2][0][6]=0;
	//BusStop[3][0][6]=0;
	//BusStop[4][0][6]=1;

	//BusStop[0][1][6]=1;
	//BusStop[1][1][6]=0;
	//BusStop[2][1][6]=0;
	//BusStop[3][1][6]=0;
	//BusStop[4][1][6]=1;

	//BusStop[0][2][6]=0;
	//BusStop[1][2][6]=1;
	//BusStop[2][2][6]=0;
	//BusStop[3][2][6]=0;
	//BusStop[4][2][6]=0;

	//BusStop[0][0][7]=1;
	//BusStop[1][0][7]=0;
	//BusStop[2][0][7]=0;
	//BusStop[3][0][7]=0;
	//BusStop[4][0][7]=1;

	//BusStop[0][1][7]=1;
	//BusStop[1][1][7]=0;
	//BusStop[2][1][7]=0;
	//BusStop[3][1][7]=0;
	//BusStop[4][1][7]=1;

	//BusStop[0][2][7]=0;
	//BusStop[1][2][7]=1;
	//BusStop[2][2][7]=0;
	//BusStop[3][2][7]=0;
	//BusStop[4][2][7]=0;

	//BusStop[0][0][8]=1;
	//BusStop[1][0][8]=0;
	//BusStop[2][0][8]=0;
	//BusStop[3][0][8]=0;
	//BusStop[4][0][8]=1;

	//BusStop[0][1][8]=1;
	//BusStop[1][1][8]=0;
	//BusStop[2][1][8]=0;
	//BusStop[3][1][8]=0;
	//BusStop[4][1][8]=1;

	//BusStop[0][2][8]=0;
	//BusStop[1][2][8]=1;
	//BusStop[2][2][8]=0;
	//BusStop[3][2][8]=0;
	//BusStop[4][2][8]=0;

	//BusStop[0][0][9]=1;
	//BusStop[1][0][9]=0;
	//BusStop[2][0][9]=0;
	//BusStop[3][0][9]=0;
	//BusStop[4][0][9]=1;

	//BusStop[0][1][9]=1;
	//BusStop[1][1][9]=0;
	//BusStop[2][1][9]=0;
	//BusStop[3][1][9]=0;
	//BusStop[4][1][9]=1;

	//BusStop[0][2][9]=0;
	//BusStop[1][2][9]=1;
	//BusStop[2][2][9]=0;
	//BusStop[3][2][9]=0;
	//BusStop[4][2][9]=0;*/
	for(k=0;k<Num_Int;k++)
	{
		// start stop i 
		for(i=0;i<BusStopNum;i++)
		{
			// calculate the bus volume when approaching stop i
			if(i==0) // terminal stop
			{
				for(b=0;b<BusNum;b++)
				{
					for(j=1;j<BusStopNum;j++) 
						TotalBusVolume[k][b][i] = TotalBusVolume[k][b][i] + BusVolume[k][b][i][j];
				}
			}
			else
			{
				for(b=0;b<BusNum;b++)
				{
					for(j=i+1;j<(BusStopNum+1);j++)  // not include BusVolume[k][b][i][i], since they already left buses when reach stop i, which leads to vacancy for boarding passengers
						TotalBusVolume[k][b][i] = TotalBusVolume[k][b][i] + BusVolume[k][b][i][j];
				}
			}
			/**************************************************************************************/
			// calculate boarding passengers
			if(i==0)
			{
						// calculate the number of stopped buses of trip k at stop i
						for(b=0;b<BusNum;b++)
						{
							if (BusStop[k][b][i]==1)
								StopVeh[k][i] = StopVeh[k][i] + 1;
						}

						int count = 0;
						// boarding flow according to stop demand: \sum_{b} B_b,i,j(k) <= P_i,j(k)
						for(j=i+1;j<BusStopNum;j++) 
						{
							// assign random value for partition ratio (sum_bus)
							for(m=0;m<StopVeh[k][i]-1;m++)
							{ 
								fraction_bus[m] = ((double) rand() / (RAND_MAX)); // value between 0 and 1
							}
							// boarding passenger volume according to the demand, bus_sum:  \sum_{b} B_{b,i,j}(k) <= P_{i,j}(k)
							for(b=0;b<BusNum;b++)
							{ 
								// if the destination stop is not assigned, then passengers with that destination stop cannot board on bus
								//if(BusStop[k][b][j]==1)
								//{
									if(StopVeh[k][i] == 1) // only one bus is coming
									{
										if (BusStop[k][b][i]==1)
										{
											BoardVolume_bus[k][b][i][j] = StopVolume[k][i][j]; // 
										}
									}
									else // arbitrarily generate the volume for boarding passengers when a bus platoon is coming
									{
										if (BusStop[k][b][i]==1)
										{
											if(count<StopVeh[k][i]-1)
												BoardVolume_bus[k][b][i][j] = StopVolume[k][i][j] * fraction_bus[count];
											else
												BoardVolume_bus[k][b][i][j] = StopVolume[k][i][j];

											for(r=0;r<count;r++)
											{
												BoardVolume_bus[k][b][i][j] = BoardVolume_bus[k][b][i][j]*(1-fraction_bus[r]);
											}
											count = count +1;
										}
									}
								//}
								//else
								//{
								//	BoardVolume_bus[k][b][i][j] = 0;
								//}
							}
							count = 0;
						}
						//// boarding flow according to fixed dwell time: BoardTime * \sum_{j} B_b,i,j(k) <= (DwellTime - DoorOpenTime)
						for(b=0;b<BusNum;b++)
						{	
							// assign random value for partition ratio (sum_j)
							for(m=0;m<BusStopNum;m++)
							{
								fraction_time[m] = ((double) rand() / (RAND_MAX)); // value between 0 and 1
							}
							for(j=i+1;j<BusStopNum;j++) 
							{
								// if the destination stop is not assigned, then passengers with that destination stop cannot board on bus
								//if(BusStop[k][b][j]==1)
								//{
									if(i == BusStopNum-1) // for final stop, only one OD pair
									{
										if (BusStop[k][b][i]==1)
										{
											BoardVolume_time[k][b][i][j] = (DwellTime - OpenTime)/BoardTime; // 
										}
									}
									else // arbitrarily generate the volume for boarding passengers when a bus platoon is coming
									{
										if (BusStop[k][b][i]==1)
										{
											if(count<(BusStopNum-i-2))
												BoardVolume_time[k][b][i][j] = ((DwellTime - OpenTime)/BoardTime) * fraction_time[count];
											else
												BoardVolume_time[k][b][i][j] = (DwellTime - OpenTime)/BoardTime;

											for(r=0;r<count;r++)
											{
												BoardVolume_time[k][b][i][j] = BoardVolume_time[k][b][i][j]*(1-fraction_time[r]);
											}
											count = count +1;
										}
									}
								//}
								//else
								//{
								//	BoardVolume_time[k][b][i][j] = 0;
								//}
							}
							count = 0;
						}
						// boarding flow according to bus remaining space: \sum_{j} B_b,i,j(k) <= Cap_b -\sum_{j} V_b,i,j(k)
						for(b=0;b<BusNum;b++)
						{	
							// assign random value for partition ratio (sum_j)
							for(m=0;m<BusStopNum;m++)
							{
								fraction_stop[m] = ((double) rand() / (RAND_MAX)); // value between 0 and 1
							}
						   // boarding passenger volume according to stop_sum:  \sum_{j} B_{b,i,j}(k) <= C_b - \sum_{j} V_{b,i,j}(k)
							for(j=i+1;j<BusStopNum;j++) 
							{ 
								// if the destination stop is not assigned, then passengers with that destination stop cannot board on bus
								//if(BusStop[k][b][j]==1)
								//{
									if(i == BusStopNum-1) // for final stop, only one OD pair
									{
										if (BusStop[k][b][i]==1)
										{
											BoardVolume_stop[k][b][i][j] = MaxBusSpace - TotalBusVolume[k][b][i]; // 
										}
									}
									else // arbitrarily generate the volume for boarding passengers when a bus platoon is coming
									{
										if (BusStop[k][b][i]==1)
										{
											if(count<(BusStopNum-i-2))
												BoardVolume_stop[k][b][i][j] = (MaxBusSpace - TotalBusVolume[k][b][i]) * fraction_stop[count];
											else
												BoardVolume_stop[k][b][i][j] = MaxBusSpace - TotalBusVolume[k][b][i];

											for(r=0;r<count;r++)
											{
												BoardVolume_stop[k][b][i][j] = BoardVolume_stop[k][b][i][j]*(1-fraction_stop[r]);
											}
											count = count +1;
										}
									}
								//}
								//else
								//{
								//	BoardVolume_stop[k][b][i][j] = 0;
								//}
							}
							count = 0;
						}

						// Final Boarding passenger 
						for(b=0;b<BusNum;b++)
						{							
							for(j=i+1;j<BusStopNum;j++) 
							{ 
								BoardVolume[k][b][i][j] = min( min ( BoardVolume_stop[k][b][i][j], BoardVolume_time[k][b][i][j]), BoardVolume_bus[k][b][i][j]);
								//BoardVolume[k][b][i][j] = min( BoardVolume_stop[k][b][i][j], BoardVolume_bus[k][b][i][j]);
							}
						}
			}
			else
			{
						// calculate the number of stopped buses of trip k at stop i
						for(b=0;b<BusNum;b++)
						{
							if (BusStop[k][b][i]==1)
								StopVeh[k][i] = StopVeh[k][i] + 1;
						}

						int count = 0;
						// boarding flow according to stop demand: \sum_{b} B_b,i,j(k) <= P_i,j(k)
						for(j=i+1;j<(BusStopNum+1);j++) 
						{		
							// assign random value for partition ratio (sum_bus)
							for(m=0;m<StopVeh[k][i]-1;m++)
							{
								fraction_bus[m] = ((double) rand() / (RAND_MAX)); // value between 0 and 1
							}
							// boarding passenger volume according to the demand, bus_sum:  \sum_{b} B_{b,i,j}(k) <= P_{i,j}(k)
							for(b=0;b<BusNum;b++)
							{ 
								// if the destination stop is not assigned, then passengers with that destination stop cannot board on bus
								//if( (BusStop[k][b][j]==1) | j==BusStopNum) // j==BusStopNum (N_s+1) since bus will all return the terminal, so it definitely need to stop at the terminal
								//{
									if(StopVeh[k][i] == 1) // only one bus is coming
									{
										if (BusStop[k][b][i]==1)
										{
											BoardVolume_bus[k][b][i][j] = StopVolume[k][i][j]; // 
										}
									}
									else // arbitrarily generate the volume for boarding passengers when a bus platoon is coming
									{
										if (BusStop[k][b][i]==1)
										{
											if(count<StopVeh[k][i]-1)
												BoardVolume_bus[k][b][i][j] = StopVolume[k][i][j] * fraction_bus[count];
											else
												BoardVolume_bus[k][b][i][j] = StopVolume[k][i][j];

											for(r=0;r<count;r++)
											{
												BoardVolume_bus[k][b][i][j] = BoardVolume_bus[k][b][i][j]*(1-fraction_bus[r]);
											}
											count = count +1;
										}
									}	
								//}
								//else
								//{
								//	BoardVolume_bus[k][b][i][j] = 0;
								//}
							}
							count = 0;
						 }
						//// boarding flow according to fixed dwell time: BoardTime * \sum_{j} B_b,i,j(k) <= (DwellTime - DoorOpenTime)
						for(b=0;b<BusNum;b++)
						{	
							// assign random value for partition ratio (sum_j)
							for(m=0;m<BusStopNum;m++)
							{
								fraction_time[m] = ((double) rand() / (RAND_MAX)); // value between 0 and 1
							}
						   
							for(j=i+1;j<(BusStopNum+1);j++) 
							{ 
								// if the destination stop is not assigned, then passengers with that destination stop cannot board on bus
								//if( (BusStop[k][b][j]==1) | j==BusStopNum) // j==BusStopNum (N_s+1) since bus will all return the terminal, so it definitely need to stop at the terminal
								//{
									if(i == BusStopNum-1) // for final stop, only one OD pair
									{
										if (BusStop[k][b][i]==1)
										{
											BoardVolume_time[k][b][i][j] = (DwellTime - OpenTime)/BoardTime; // 
										}
									}
									else // arbitrarily generate the volume for boarding passengers when a bus platoon is coming
									{
										if (BusStop[k][b][i]==1)
										{
											if(count<(BusStopNum-i-1))
												BoardVolume_time[k][b][i][j] = ((DwellTime - OpenTime)/BoardTime) * fraction_time[count];
											else
												BoardVolume_time[k][b][i][j] = (DwellTime - OpenTime)/BoardTime;

											for(r=0;r<count;r++)
											{
												BoardVolume_time[k][b][i][j] = BoardVolume_time[k][b][i][j]*(1-fraction_time[r]);
											}
											count = count +1;
										}
									}
								//}
								//else
								//{
								//	BoardVolume_time[k][b][i][j] = 0;
								//}
							}
							count = 0;
						}
						// boarding flow according to bus remaining space: \sum_{j} B_b,i,j(k) <= Cap_b -\sum_{j} V_b,i,j(k)
						for(b=0;b<BusNum;b++)
						{	
							// assign random value for partition ratio (sum_j)
							for(m=0;m<(BusStopNum);m++)
							{
								fraction_stop[m] = ((double) rand() / (RAND_MAX)); // value between 0 and 1
							}
	
							for(j=i+1;j<(BusStopNum+1);j++) 
							{ 
								// if the destination stop is not assigned, then passengers with that destination stop cannot board on bus
								//if( (BusStop[k][b][j]==1) | j==BusStopNum) // j==BusStopNum (N_s+1) since bus will all return the terminal, so it definitely need to stop at the terminal
								//{
									if(i == BusStopNum-1) // for final stop, only one OD pair
									{
										if (BusStop[k][b][i]==1)
										{
											BoardVolume_stop[k][b][i][j] = MaxBusSpace - TotalBusVolume[k][b][i]; // 
										}
									}
									else // arbitrarily generate the volume for boarding passengers when a bus platoon is coming
									{
										if (BusStop[k][b][i]==1)
										{
											if(count<(BusStopNum-i-1))
												BoardVolume_stop[k][b][i][j] = (MaxBusSpace - TotalBusVolume[k][b][i]) * fraction_stop[count];
											else
												BoardVolume_stop[k][b][i][j] = MaxBusSpace - TotalBusVolume[k][b][i];

											for(r=0;r<count;r++)
											{
												BoardVolume_stop[k][b][i][j] = BoardVolume_stop[k][b][i][j]*(1-fraction_stop[r]);
											}
											count = count +1;
										}
									}	
								//}
								//else
								//{
								//	BoardVolume_stop[k][b][i][j] = 0;
								//}
							}
							count = 0;
						}

						// Final Boarding passenger 
						for(b=0;b<BusNum;b++)
						{							
							for(j=i+1;j<(BusStopNum+1);j++) 
							{ 
								BoardVolume[k][b][i][j] = min( min ( BoardVolume_stop[k][b][i][j], BoardVolume_time[k][b][i][j]), BoardVolume_bus[k][b][i][j]); //  
								//BoardVolume[k][b][i][j] = min( BoardVolume_stop[k][b][i][j], BoardVolume_bus[k][b][i][j]);
							}
						}
			}
			/**************************************************************************************/
			// Bus Volume update
			if (i==0)
			{
				for(j=1;j<(BusStopNum);j++) 
				{
					for(b=0;b<BusNum;b++)
					{
						BusVolume[k][b][i+1][j] = BusVolume[k][b][i][j] + BoardVolume[k][b][i][j];
					}
				}
			}
			else
			{
				for(j=i+1;j<(BusStopNum+1);j++) 
				{
					for(b=0;b<BusNum;b++)
				    {
						BusVolume[k][b][i+1][j] = BusVolume[k][b][i][j] + BoardVolume[k][b][i][j];
					}
				}
			}

			// loading time for bus b
			for(b=0;b<BusNum;b++)
			{
				if(BusStop[k][b][i]==1)
				{
					if(i==0)
					{
						for(j=1;j<BusStopNum;j++) 
						{
							sumboardtime = sumboardtime + BoardTime*BoardVolume[k][b][i][j];
						}	
					
						LoadTime[k][b][i]  = OpenTime + sumboardtime;
					}
					else
					{
						for(j=i+1;j<(BusStopNum+1);j++) 
						{
							sumboardtime = sumboardtime + BoardTime*BoardVolume[k][b][i][j];
						}	
						sumalighttime = AlightTime*BusVolume[k][b][i-1][i];

						LoadTime[k][b][i]  = OpenTime + max(sumboardtime, sumalighttime);
					}
				}
				sumalighttime = 0;
				sumboardtime = 0;
				
			}
			// dwell time for buses in trip k = maximum load time for buses in trip k < DwellTime (180s): fixed stopping time at each stop
			TrueDwellTime[k][i] = 0;
			for(b=0;b<BusNum;b++)
			{
				if(BusStop[k][b][i]==1)
				{
					if(TrueDwellTime[k][i]<LoadTime[k][b][i])
						TrueDwellTime[k][i] = LoadTime[k][b][i];
				}
			}
	 //   // if there are volume boarding at stop i with destination stop j on bus b and previously stop j is not assigned in prespecified schedule for bus b,
			// then bus b need to stop
			//for(b=0;b<BusNum;b++)
			//{
			//	for(j=i+1;j<(BusStopNum);j++)
			//	{
			//		if( (BoardVolume[k][b][i][j] != 0) && (BusStop[k][b][j]==0) )
			//			BusStop[k][b][j]=1;
			//	}
			//}
		 //////re-assign the bus stop (if any bus of trip k stop at stop i, then other buses in trip k should also stop ) 
			//for(b=0;b<BusNum;b++)
			//{
			//	for(j=1;j<(BusStopNum);j++)
			//	{
			//		if ((BusStop[k][b][j]==1))
			//		{
			//			for(r=0;r<BusNum;r++)
			//			{
			//				if (BusDispatch[k][r] == 1)
			//	    			BusStop[k][r][j]=1;
			//			}
			//		}
			//	}
			//}
		} // stop i

		//Stop Volume update
		for (i=0;i<BusStopNum;i++)
		{
			if(i==0)
			{
				for(j=1;j<(BusStopNum);j++) 
				{
					for(b=0;b<BusNum;b++)
					{
						sum_b = sum_b + BoardVolume[k][b][i][j];
					}
					StopVolume[k+1][i][j] = StopVolume[k][i][j] + FlowIn[k][i][j]-sum_b;
					sum_b=0;
				}
			}
			else
			{
				for(j=i+1;j<(BusStopNum+1);j++) 
				{
					for(b=0;b<BusNum;b++)
					{
						sum_b = sum_b + BoardVolume[k][b][i][j];
					}
					StopVolume[k+1][i][j] = StopVolume[k][i][j] + FlowIn[k][i][j]-sum_b;
					sum_b=0;
				}
			}
		}
	}// trip k
	
/////////////////////////*********************///////////////// (DELAY)

    for(k=0;k<Num_Int;k++)
	{
		for(i=0;i<BusStopNum;i++)
		{
			if(i==0)
			{
				for(j=1;j<(BusStopNum);j++) 
				{
					PassDelay = PassDelay + StopVolume[k][i][j];
				}
			}
			else
			{
				for(j=i+1;j<(BusStopNum+1);j++) 
				{
					PassDelay = PassDelay + StopVolume[k][i][j];
				}
			}
		}
	}

	/////////////////////////*********************///////////////// (PERCEIVED DELAY)
	for(k=0;k<Num_Int-1;k++)
	{
		for(i=0;i<BusStopNum;i++)
    	{
			for(n=k+1; n<Num_Int; n++)
			{
				if(i==0)
				{
					for(j=1;j<(BusStopNum);j++) 
					{
						for(b=0;b<BusNum;b++)
						{
							for(r=k+1;r<n+1;r++)
								AlreadyBoardVolume[n][i][j] = AlreadyBoardVolume[n][i][j]+BoardVolume[r][b][i][j];
						}
						PassDelay2 = PassDelay2 + max(FlowIn[k][i][j]-max(AlreadyBoardVolume[n][i][j]-StopVolume[k][i][j],0),0)*square(n-(k+1));
					}
				}
				else
				{
					for(j=1;j<(BusStopNum+1);j++) 
					{
						for(b=0;b<BusNum;b++)
						{
							for(r=k+1;r<n+1;r++)
								AlreadyBoardVolume[n][i][j] = AlreadyBoardVolume[n][i][j]+BoardVolume[r][b][i][j];
						}
						PassDelay2 = PassDelay2 + max(FlowIn[k][i][j]-max(AlreadyBoardVolume[n][i][j]-StopVolume[k][i][j],0),0)*square(n-(k+1));
					}
				}
			}
		}
	}
/////////////////////////*********************///////////////// (REMAIN SPACE)
	int volumenum = 0;

    for(k=0;k<Num_Int;k++)
	{
		for(b=0;b<BusNum;b++)
		{
			for(i=0;i<BusStopNum;i++)
			{
				if(i==0)
				{
					//if(BusDispatch[k][b]==1) // only the dispatched buses consider the bus vacancy
					//{
						for(j=0;j<(BusStopNum);j++) //include the alighting volume at stop i, \sum_{q}V[k][b][q][i] is considered in bus volume when bus leave stop i-1
						{
							volumenum = volumenum + BusVolume[k][b][i][j];
						}
						BusVacancy = BusVacancy + MaxBusSpace - volumenum;
						volumenum=0;
					//}
				}
				else
				{
					//if(BusDispatch[k][b]==1) // only the dispatched buses consider the bus vacancy
					//{
						for(j=i;j<(BusStopNum+1);j++) //include the alighting volume at stop i, \sum_{q}V[k][b][q][i] is considered in bus volume when bus leave stop i-1
						{
							volumenum = volumenum + BusVolume[k][b][i][j];
						}
						BusVacancy = BusVacancy + MaxBusSpace - volumenum;
						volumenum=0;
					//}
				}
			}
		}
	}

////////////////////////////////////////////////////
	for(k=0;k<Num_Int;k++)
	{
		for(i=0;i<BusStopNum;i++)
		{
			for(b=0;b<BusNum;b++)
			{
				returnvalue.dataLoadTime[k][b][i] = LoadTime[k][b][i];
			}
			returnvalue.dataTrueDwellTime[k][i] = TrueDwellTime[k][i];
		}
	}

	//for(k=0;k<Num_Int;k++)
	//{
	//	for(b=0;b<BusNum;b++)
	//	{
	//		for(i=0;i<BusStopNum;i++)
	//		{
	//			if(i==0)
	//			{
	//				for(j=0;j<BusStopNum;j++)
	//				{
	//					returnvalue.dataBoardVolume[k][b][i][j] = BoardVolume[k][b][i][j];
	//					returnvalue.dataBusVolume[k][b][i][j] = BusVolume[k][b][i][j];
	//				}
	//			}
	//			else
	//			{
	//				for(j=0;j<BusStopNum+1;j++)
	//				{
	//					returnvalue.dataBoardVolume[k][b][i][j] = BoardVolume[k][b][i][j];
	//					returnvalue.dataBusVolume[k][b][i][j] = BusVolume[k][b][i][j];
	//				}
	//			}
	//		}
	//	}
	//}

		 returnvalue.delay = PassDelay2;
		 returnvalue.space = BusVacancy;
		 return returnvalue;
}

void fitness_cost(population *pop_ptr, int m)
{
  /*File ptr to the file to store the value of the g for last iteration
    g is the parameter required for a particular problem
    Every problem is not required*/
 
  int fit_delay,      /* bus delay */
	  fit_space;      /* bus vacancy */
  

  int i,j,k,b,index_fit,index; 
  if(m==1)
     index_fit = 0;
  if(m==2)
	 index_fit = popsize;

  /*Initializing the max rank to zero*/
  for(index = 0;index < popsize;index++)
    {
      pop_ptr->ind_ptr = &(pop_ptr->ind[index+index_fit]);

  ////////////////////////////////////////////////////////////////////
  /* calculate passenger delay and bus vacancy */
  /////////////////////////////////////////////////////////////////////
	  // every time re-initial the data setting
	for(k=0;k<(Num_Int+1);k++)
	{
		for(b=0;b<BusNum;b++)
		{
			for(i=0;i<(BusStopNum+1);i++)
			{
				for(j=0;j<(BusStopNum+1);j++)
				{
					BusVolume[k][b][i][j] = 0;
					BoardVolume[k][b][i][j]=0;
					BoardVolume_bus[k][b][i][j]=0; // do not forget, otherwise, is wrong
					BoardVolume_time[k][b][i][j] = 0; // do not forget, otherwise, is wrong
					BoardVolume_stop[k][b][i][j]=0; // do not forget, otherwise, is wrong
					if(k>0)
						StopVolume[k][i][j]=0;
				}
				TotalBoardVolume[k][b][i] = 0;
				TotalBusVolume[k][b][i] = 0;
				LoadTime[k][b][i] = 0;
			}
			TrueDwellTime[k][i] = 0;
		}
	  }

	  data totalcost;
	 //delay cost
		totalcost=Calculate_Bus_Cost(pop_ptr->ind_ptr->genes_dispatch, pop_ptr->ind_ptr->genes_stop);
		fit_delay = totalcost.delay;
		fit_space = totalcost.space;

	//for(k=0;k<Num_Int;k++)
	//{
	//	for(b=0;b<BusNum;b++)
	//	{
	//		for(i=0;i<BusStopNum;i++)
	//		{
	//			if(i==0)
	//			{
	//				for(j=0;j<BusStopNum;j++)
	//				{
	//					pop_ptr->ind_ptr->boardvolume[k][b][i][j]=totalcost.dataBoardVolume[k][b][i][j];
	//					pop_ptr->ind_ptr->busvolume[k][b][i][j]=totalcost.dataBusVolume[k][b][i][j];
	//				}
	//			}
	//			else
	//			{
	//				for(j=0;j<BusStopNum+1;j++)
	//				{
	//					pop_ptr->ind_ptr->boardvolume[k][b][i][j]=totalcost.dataBoardVolume[k][b][i][j];
	//					pop_ptr->ind_ptr->busvolume[k][b][i][j]=totalcost.dataBusVolume[k][b][i][j];
	//				}
	//			}
	//		}
	//	}
	//}

	for(k=0;k<(Num_Int+1);k++)
	{
		for(i=0;i<BusStopNum;i++)
		{
			for(b=0;b<BusNum;b++)
			{
				pop_ptr->ind_ptr->DataLoadTime[k][b][i] = totalcost.dataLoadTime[k][b][i];
			}
			pop_ptr->ind_ptr->DataTrueDwellTime[k][i] = totalcost.dataTrueDwellTime[k][i];
		}
	}
		pop_ptr->ind_ptr->fitness = fit_delay + fit_space;
		pop_ptr->ind_ptr->space = fit_space;
		pop_ptr->ind_ptr->delay = fit_delay;
  }
  pop_ptr->ind_ptr = &(pop_ptr->ind[0]);
  	/* check newly added part*/
	//for(i=0;i<popsize;i++)
	//{
	//	
	//	pop_ptr->ind_ptr= &(pop_ptr->ind[i]);
	//	double m = 2;
	//}

}