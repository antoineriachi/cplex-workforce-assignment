/*********************************************
 * OPL 12.8.0.0 Model
 * Author: anthonyriachy
 * Creation Date: Mar 6, 2020 at 4:27:59 PM
 *********************************************/
 
// Indices & Sets
int NbOfEes = 8;
range EeID = 1..NbOfEes;
int NbShifts = 12; // each shift is 2 hours
range Shift = 1..NbShifts;
int NbDays =7;
range Day = 1..NbDays;
int DaysWorked = 5;
int S = 7200; // availability of an employee in a two-hour shift in seconds where S = 3600*2
float p = 0.9; // productivity of an employee
int M = 100000;
int NumberFT=4;

// Parameters
int HiringCost = 4000;
int CallTrainingCost = 3000;
int ChatTrainingCost = 3000;
int MultiTrainingCost = 6000;
int CallHourlyCost = 19;
int ChatHourlyCost = 19;
int MultiHourlyCost = 23;

float CallDemand[Shift][Day]=...; 
float ChatDemand[Shift][Day]=...;

// Decision Variables
// 1 if employee i works on shift j, on day k; 0 otherwise
dvar boolean x[EeID][Shift][Day]; //call
dvar boolean y[EeID][Shift][Day]; //chat
dvar boolean z[EeID][Shift][Day]; //call & chat

// 1 if employee i is hired; 0 otherwise
dvar boolean xx[EeID]; //call
dvar boolean yy[EeID]; //chat
dvar boolean zz[EeID]; //call & chat

// 1 if employee i works on day k; 0 otherwise
dvar boolean xp[EeID][Day]; //call
dvar boolean yp[EeID][Day]; //chat
dvar boolean zp[EeID][Day]; //call & chat

// 1 if employee i starts working on shift j, on day k; 0 otherwise
dvar boolean a[EeID][Shift][Day]; //call 
dvar boolean b[EeID][Shift][Day]; //chat
dvar boolean c[EeID][Shift][Day]; //call & chat

// 1 if employee i works on shift j, and worked on shift j-1 on day k; 0 otherwise
dvar boolean f[EeID][Shift][Day]; //call
dvar boolean e[EeID][Shift][Day]; //chat
dvar boolean d[EeID][Shift][Day]; //call & chat

// Objective function
minimize    sum(i in EeID) HiringCost * (xx[i]+yy[i]+zz[i]) +
            sum(i in EeID) CallTrainingCost * xx[i] +
            sum(i in EeID) ChatTrainingCost * yy[i] +
            sum(i in EeID) MultiTrainingCost * zz[i] +
            sum(i in EeID, j in Shift, k in Day) 2 * CallHourlyCost * x[i][j][k]+
            sum(i in EeID, j in Shift, k in Day) 2 * ChatHourlyCost * y[i][j][k]+
            sum(i in EeID, j in Shift, k in Day) 2 * MultiHourlyCost * z[i][j][k];

subject to
{
// 1. Required number of hours worked in a day for full-time and part-time employees 
// Full-time employees
forall (i in EeID:i<=NumberFT, k in Day) 
{
	//call
    sum(j in Shift) x[i][j][k] + M * (1 - xp[i][k]) >= 4; // 4 shifts * 2hours/shift = 8 hours/day
    sum(j in Shift) x[i][j][k] <= M * xp[i][k];
    sum(j in Shift) x[i][j][k] <= 4;
	//chat
    sum(j in Shift) y[i][j][k] + M * (1 - yp[i][k]) >= 4; 
    sum(j in Shift) y[i][j][k] <= M * yp[i][k];
    sum(j in Shift) y[i][j][k] <= 4;
	//call & chat
    sum(j in Shift) z[i][j][k] + M * (1 - zp[i][k]) >= 4; 
    sum(j in Shift) z[i][j][k] <= M * zp[i][k];
    sum(j in Shift) z[i][j][k] <= 4;
}
// Part-time employees
forall (i in EeID:i>NumberFT, k in Day) 
{
	//call
    sum(j in Shift) x[i][j][k] + M * (1 - xp[i][k]) >= 2;
    sum(j in Shift) x[i][j][k] <= M * xp[i][k];
	//chat
    sum(j in Shift) y[i][j][k] + M * (1 - yp[i][k]) >= 2;
    sum(j in Shift) y[i][j][k] <= M * yp[i][k];
	//call & chat
    sum(j in Shift) z[i][j][k] + M * (1 - zp[i][k]) >= 2;
    sum(j in Shift) z[i][j][k] <= M * zp[i][k];
}

// 2. Maximum number of days worked in a week for employees
forall (i in EeID)
{
    sum(k in Day) xp[i][k] <= DaysWorked;
    sum(k in Day) yp[i][k] <= DaysWorked;
    sum(k in Day) zp[i][k] <= DaysWorked;
}  

// 3. Maximum number of two-hour shifts worked in a week
// Full-time employees
forall (i in EeID:i<=NumberFT)
{
    sum(j in Shift, k in Day) x[i][j][k] <= 20; // 20 shifts * 2hours/shift = 40 hours/week
    sum(j in Shift, k in Day) y[i][j][k] <= 20;
    sum(j in Shift, k in Day) z[i][j][k] <= 20;
}   
// Part-time employees
forall (i in EeID:i>NumberFT)
{
    sum(j in Shift, k in Day) x[i][j][k] <= 12; // 12 shifts * 2hours/shift = 24 hours/week
    sum(j in Shift, k in Day) y[i][j][k] <= 12;
    sum(j in Shift, k in Day) z[i][j][k] <= 12;
}

// 4. Consecutive shifts constraint for full-time and part-time employees
forall(i in EeID, j in Shift: j >1, k in Day)
{
    f[i][j][k] >= x[i][j][k] + x[i][j-1][k] - 1; //call
    2 * f[i][j][k] <= x[i][j][k] + x[i][j-1][k];
    e[i][j][k] >= y[i][j][k] + y[i][j-1][k] - 1; //chat
    2 * e[i][j][k] <= y[i][j][k] + y[i][j-1][k];
    d[i][j][k] >= z[i][j][k] + z[i][j-1][k] - 1; //call & chat
    2 * d[i][j][k] <= z[i][j][k] + z[i][j-1][k];
}
// 4.1 a, b, and c are used to track when employee i start working on day k
forall(i in EeID, j in Shift, k in Day)
{
    a[i][j][k] == x[i][j][k]-f[i][j][k]; // call
    b[i][j][k] == y[i][j][k]-e[i][j][k]; // chat
    c[i][j][k] == z[i][j][k]-d[i][j][k]; // call & chat 
    
	//a, b, and c for first shift of the day
    a[i][1][k] == x[i][1][k]; // call
    b[i][1][k] == y[i][1][k]; // chat
    c[i][1][k] == z[i][1][k]; // call & chat
}

// 4.3 if full-time employee i starts at shift j on day k, he must work the next 3 shifts
forall (i in EeID:i<=NumberFT, j in 1..9, k in Day)
{
    sum(q in 0..3) x[i][j+3-q][k] - 3 <= a[i][j][k]; //call
    sum(q in 0..3) x[i][j+3-q][k] >= 4 * a[i][j][k];
    sum(q in 0..3) y[i][j+3-q][k] - 3 <= b[i][j][k]; //chat
    sum(q in 0..3) y[i][j+3-q][k] >= 4 * b[i][j][k];
    sum(q in 0..3) z[i][j+3-q][k] - 3 <= c[i][j][k]; //call & chat
    sum(q in 0..3) z[i][j+3-q][k] >= 4 * c[i][j][k];
}
// 4.4 if part-time employee i starts at shift j on day k, he must work the next shift
forall (i in EeID:i>NumberFT, j in 1..11, k in Day)
{
    sum(q in 0..1) x[i][j+1-q][k] - 1 <= a[i][j][k]; //call
    sum(q in 0..1) x[i][j+1-q][k] >= 2 * a[i][j][k];
    sum(q in 0..1) y[i][j+1-q][k] - 1 <= b[i][j][k]; //chat
    sum(q in 0..1) y[i][j+1-q][k] >= 2 * b[i][j][k];
    sum(q in 0..1) z[i][j+1-q][k] - 1 <= c[i][j][k]; //call & chat
    sum(q in 0..1) z[i][j+1-q][k] >= 2 * c[i][j][k];
}

// 5. employees can only start working on specific shifts on a day k
//full-time employee cannot start working on shifts 10,11 or 12
forall(i in EeID:i<=NumberFT, k in Day)
{
    a[i][10][k]+a[i][11][k]+a[i][12][k]==0; //call
    sum(j in 1..9) a[i][j][k]<=1;
    b[i][10][k]+b[i][11][k]+b[i][12][k]==0; //chat
    sum(j in 1..9) b[i][j][k]<=1;
    c[i][10][k]+c[i][11][k]+c[i][12][k]==0; //call & chat
    sum(j in 1..9) c[i][j][k]<=1;
}
// part time employee cannot start working on shift  12 
forall(i in EeID:i>NumberFT, k in Day)
{
    a[i][12][k]==0; //call
    sum(j in 1..11) a[i][j][k]<=1;
    b[i][12][k]==0; //chat
    sum(j in 1..11) b[i][j][k]<=1;
    c[i][12][k]==0; //call & chat
    sum(j in 1..11) c[i][j][k]<=1;
}

// 6. Employees working should get at least 12 hours of break before their next start shift 
// Full-time employees
forall(i in EeID:i<=NumberFT, k in Day:k < 7)
{
  //call
  sum(j in 1..6)a[i][j][k+1] <= M*(1-a[i][9][k]);
  sum(j in 1..5)a[i][j][k+1] <= M*(1-a[i][8][k]);
  sum(j in 1..4)a[i][j][k+1] <= M*(1-a[i][7][k]);
  sum(j in 1..3)a[i][j][k+1] <= M*(1-a[i][6][k]);
  sum(j in 1..2)a[i][j][k+1] <= M*(1-a[i][5][k]);
  a[i][1][k+1] <= M*(1-a[i][4][k]);
  //call
  sum(j in 1..6)b[i][j][k+1] <= M*(1-b[i][9][k]);
  sum(j in 1..5)b[i][j][k+1] <= M*(1-b[i][8][k]);
  sum(j in 1..4)b[i][j][k+1] <= M*(1-b[i][7][k]);
  sum(j in 1..3)b[i][j][k+1] <= M*(1-b[i][6][k]);
  sum(j in 1..2)b[i][j][k+1] <= M*(1-b[i][5][k]);
  b[i][1][k+1] <= M*(1-b[i][4][k]);
  //call & chat
  sum(j in 1..6)c[i][j][k+1] <= M*(1-c[i][9][k]);
  sum(j in 1..5)c[i][j][k+1] <= M*(1-c[i][8][k]);
  sum(j in 1..4)c[i][j][k+1] <= M*(1-c[i][7][k]);
  sum(j in 1..3)c[i][j][k+1] <= M*(1-c[i][6][k]);
  sum(j in 1..2)c[i][j][k+1] <= M*(1-c[i][5][k]);
  c[i][1][k+1] <= M*(1-c[i][4][k]);  
}

// Part-time employees
forall(i in EeID:i>NumberFT, k in Day:k < 7)
{
  //call
  sum(j in 1..6)a[i][j][k+1] <= M*(1-a[i][11][k]);
  sum(j in 1..5)a[i][j][k+1] <= M*(1-a[i][10][k]);
  sum(j in 1..4)a[i][j][k+1] <= M*(1-a[i][9][k]);
  sum(j in 1..3)a[i][j][k+1] <= M*(1-a[i][8][k]);
  sum(j in 1..2)a[i][j][k+1] <= M*(1-a[i][7][k]);
  a[i][1][k+1] <= M*(1-a[i][6][k]);
  //chat
  sum(j in 1..6)b[i][j][k+1] <= M*(1-b[i][11][k]);
  sum(j in 1..5)b[i][j][k+1] <= M*(1-b[i][10][k]);
  sum(j in 1..4)b[i][j][k+1] <= M*(1-b[i][9][k]);
  sum(j in 1..3)b[i][j][k+1] <= M*(1-b[i][8][k]);
  sum(j in 1..2)b[i][j][k+1] <= M*(1-b[i][7][k]);
  b[i][1][k+1] <= M*(1-b[i][6][k]);
  //call & chat
  sum(j in 1..6)c[i][j][k+1] <= M*(1-c[i][11][k]);
  sum(j in 1..5)c[i][j][k+1] <= M*(1-c[i][10][k]);
  sum(j in 1..4)c[i][j][k+1] <= M*(1-c[i][9][k]);
  sum(j in 1..3)c[i][j][k+1] <= M*(1-c[i][8][k]);
  sum(j in 1..2)c[i][j][k+1] <= M*(1-c[i][7][k]);
  c[i][1][k+1] <= M*(1-c[i][6][k]);  
}

// 7. Number of call and chat requests must be met in a shift by employees working on said shift
forall(j in Shift, k in Day)
{
   //assuming that multiskilled is working 60% on Call whereas singleskilled is 100% dedicated
   sum(i in EeID) (x[i][j][k]*S*p + z[i][j][k]*S*p*0.6) >= CallDemand[j][k]; 
   //assuming that multiskilled is working 40% on Chat whereas singleskilled is 100% dedicated
   sum(i in EeID) (y[i][j][k]*S*p + z[i][j][k]*S*p*0.4) >= ChatDemand[j][k]; 
}

// 8. An employee is hired if he works at least one day
forall (i in EeID)
{
    sum(l in Day) xp[i][l] + M * (1 - xx[i]) >= 1; //call
    sum(l in Day) xp[i][l] <= M * xx[i];
    sum(l in Day) yp[i][l] + M * (1 - yy[i]) >= 1; //chat
    sum(l in Day) yp[i][l] <= M * yy[i];
    sum(l in Day) zp[i][l] + M * (1 - zz[i]) >= 1; //call & chat
    sum(l in Day) zp[i][l] <= M * zz[i];
}
}