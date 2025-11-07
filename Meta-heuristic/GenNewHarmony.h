#define HMCR 0.95
#define PAR  0.5

void Gene_New_Harmony(population *new_pop_ptr, population *pop_ptr)
{
	double ra, ra2;
	int i,j,k,l,b,r, ind;

	new_pop_ptr->ind_ptr = &(new_pop_ptr->ind[0]);
	pop_ptr->ind_ptr = &(pop_ptr->ind[0]);

		for (l=0;l<popsize;l++)
		{
				for(b=0;b<BusNum;b++)
				{	
					for(k=0;k<Num_Int;k++)
					{
						ra = ((double)rand()) / ((double)RAND_MAX);
						if(ra<HMCR) 
						{ 
							ra2 = ((double)rand()) / ((double)RAND_MAX);
							if(ra2<PAR)
							{
								ind = rand()%popsize;
								new_pop_ptr->ind_ptr->genes_dispatch[k][b] = ((pop_ptr->ind_ptr)+(ind%(popsize/2)))->genes_dispatch[k][b];	
								/*for(j=0;j<BusStopNum;j++)
								{									
									new_pop_ptr->ind_ptr->genes_stop[k][b][j] = ((pop_ptr->ind_ptr)+(ind%(popsize/2)))->genes_stop[k][b][j];															
								}*/
							}
							else
							{
								new_pop_ptr->ind_ptr->genes_dispatch[k][b] = (pop_ptr->ind_ptr)->genes_dispatch[k][b];	
								/*for(j=0;j<BusStopNum;j++)
								{										
									new_pop_ptr->ind_ptr->genes_stop[k][b][j] = (pop_ptr->ind_ptr)->genes_stop[k][b][j];														
								}*/
							}																					
						}//HMCR		
						else{
								for(j=0;j<BusStopNum;j++)
								{
									new_pop_ptr->ind_ptr->genes_dispatch[k][b]= rand()%2;
									/* Generate a Random No. */

									// adjust dispatch
									if(k>0)
									{
										for(r=0;r<k;r++)
										{
											if (new_pop_ptr->ind_ptr->genes_dispatch[r][b] ==1)
											{
												if (k<(r+returnHorizon))
													new_pop_ptr->ind_ptr->genes_dispatch[k][b] = 0;
											}

										}
									}
								}//for
									// generate associated stop indicator
									//if(new_pop_ptr->ind_ptr->genes_dispatch[k][b]==0) // x_b(k) = 0 --> Q_b,j(k)=0
									//{
									//	for(j=0;j<BusStopNum;j++)
									//	{
									//		new_pop_ptr->ind_ptr->genes_stop[k][b][j]= 0;
		 						//		}
									//}
									//else
									//{
									//	for(j=0;j<BusStopNum;j++)
									//	{
									//		new_pop_ptr->ind_ptr->genes_stop[k][b][j]= rand()%2;
									//		/*Generate a Random No. */
									//	}
									//}

								}//else			
							}//k
						}//b

					// adjust dispatch
					for(b=0;b<BusNum;b++)
					{	
						for(k=0;k<Num_Int;k++)
						{
							if(k>0)
							{
								for(j=0;j<k;j++)
								{
									if (new_pop_ptr->ind_ptr->genes_dispatch[j][b] ==1)
									{
										if (k<(j+returnHorizon))
											new_pop_ptr->ind_ptr->genes_dispatch[k][b] = 0;
									}

								}
							}
						}
					}
					// assign stops for changed x_b(k)
					for(k=0;k<Num_Int;k++)
					{
						for(b=0;b<BusNum;b++)
						{
							for(j=0;j<BusStopNum;j++)
						    {
								if(new_pop_ptr->ind_ptr->genes_dispatch[k][b]==0)
									new_pop_ptr->ind_ptr->genes_stop[k][b][j]=0;
								else
									new_pop_ptr->ind_ptr->genes_stop[k][b][j]=1;
							}
						}
					}


				//// re-assign the bus stop (if any bus of trip k stop at stop i, then buses in trip k should also stop ) 
				/*for(k=0;k<Num_Int;k++)
				{
					for(b=0;b<BusNum;b++)
						{	
							for(j=0;j<BusStopNum;j++)
							{
								for(r=0;r<BusNum;r++)
								{
									if ((new_pop_ptr->ind_ptr->genes_stop[k][r][j]==1) && (new_pop_ptr->ind_ptr->genes_dispatch[k][b]==1))
										new_pop_ptr->ind_ptr->genes_stop[k][b][j]=1;
								}
							}
					}
				}*/
			// update the pointer
			new_pop_ptr->ind_ptr = &(new_pop_ptr->ind[l+1]);
			pop_ptr->ind_ptr = &(pop_ptr->ind[l+1]);
	}//popsize
			
			
		new_pop_ptr->ind_ptr = &(new_pop_ptr->ind[0]);

		pop_ptr->ind_ptr = &(pop_ptr->ind[popsize]); // add child offspring after original pop (old pop)

		for(i=0;i<popsize;i++)
		{			
			for(k=0;k<Num_Int;k++)
			{
				for(b=0;b<BusNum;b++)
				{
					pop_ptr->ind_ptr->genes_dispatch[k][b] = new_pop_ptr->ind_ptr->genes_dispatch[k][b];
					for(j=0;j<BusStopNum;j++)
					{
						pop_ptr->ind_ptr->genes_stop[k][b][j] = new_pop_ptr->ind_ptr->genes_stop[k][b][j];
					}
				}
			}
			new_pop_ptr->ind_ptr = &(new_pop_ptr->ind[i+1]);
			pop_ptr->ind_ptr = &(pop_ptr->ind[popsize+i+1]);
		}
		pop_ptr->ind_ptr = &(pop_ptr->ind[0]);
		/* check newly added part on old pop */
		//for(i=0;i<popsize;i++)
		//{
		//	pop_ptr->ind_ptr = &(pop_ptr->ind[popsize+i]);
		//	int m=0;

		//}
}