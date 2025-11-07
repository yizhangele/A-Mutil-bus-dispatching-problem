/*This is the file which initializes the population*/
void init(population *pop_ptr);

void init(population *pop_ptr)
{
  int i,j,k,b,r;
  pop_ptr->ind_ptr = &(pop_ptr->ind[0]); 
  
  // generate bus trips x_b(k)
	/*Loop Over the population size*/
	for (i = 0; i < popsize ; i++)
	{   
		/*Loop over the chromosome length*/
		for (k = 0; k < Num_Int;k++)
		{
			for(b = 0; b < BusNum;b++)
			{
				pop_ptr->ind_ptr->genes_dispatch[k][b]= rand()%2;
				/* Generate a Random No. */

			   // adjust dispatch
				if(k>0)
				{
					for(j=0;j<k;j++)
					{
						if (pop_ptr->ind_ptr->genes_dispatch[j][b] ==1)
						{
							if (k<(j+returnHorizon))
								pop_ptr->ind_ptr->genes_dispatch[k][b] = 0;
						}

					}
				}
				
			}
		}
      pop_ptr->ind_ptr = &(pop_ptr->ind[i+1]);
    }
  
	pop_ptr->ind_ptr = &(pop_ptr->ind[0]); 
  // generate bus stop positions Q_b,i(k)
	for (i = 0 ; i < popsize ; i++)
	{      
		/*Loop over the chromosome length*/
		for (k = 0;k < Num_Int;k++)
		{
			for(b = 0;b < BusNum;b++)
			{
				if(pop_ptr->ind_ptr->genes_dispatch[k][b]==0) // x_b(k) = 0 --> Q_b,j(k)=0
				{
					for(j=0;j<BusStopNum;j++)
					{
						pop_ptr->ind_ptr->genes_stop[k][b][j]= 0;
		 			}
				}
				else
				{
					for(j=0;j<BusStopNum;j++)
					{
						pop_ptr->ind_ptr->genes_stop[k][b][j]= 1;
						/*Generate a Random No. */
					}
				}
			}
		 }
		// re-assign the bus stop (if any bus of trip k stop at stop i, then buses in trip k should also stop ) 
		/*for(k=0;k<Num_Int;k++)
		{
			for(b=0;b<BusNum;b++)
				{	
					for(j=0;j<BusStopNum;j++)
					{
						for(r=0;r<BusNum;r++)
						{
							if ((pop_ptr->ind_ptr->genes_stop[k][r][j]==1) && (pop_ptr->ind_ptr->genes_dispatch[k][b]==1))
								pop_ptr->ind_ptr->genes_stop[k][b][j]=1;
						}
					}
			}
		}*/
     // update the pointer
      pop_ptr->ind_ptr = &(pop_ptr->ind[i+1]);
    }
	pop_ptr->ind_ptr = &(pop_ptr->ind[0]); 

	///* check pop*/
	//for(i=0;i<popsize;i++)
	//{
	//	pop_ptr->ind_ptr = &(pop_ptr->ind[i]);
	//	double m = 2;
	//}
}
