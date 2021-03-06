//+------------------------------------------------------------------+
//|                                                  myFunctions.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//| User Defined Functions                                           |
//+------------------------------------------------------------------+

// This function generates a random number between specified high and low points
double randomBetween( double low, double high)
{
   double randomSeed = MathRand()/32767.0;
   double ans = low + randomSeed * (high - low);
   return(ans);
}


// This function returns true when a new bar is placed on the chart
bool NewBar()
{
   bool ans = false;
   static datetime lastBarOpenTime;
   datetime thisBarOpenTime = Time[0];
   if( thisBarOpenTime != lastBarOpenTime )
   {
      lastBarOpenTime = thisBarOpenTime;
      ans = true;
   }
   else
      ans = false;
      
   return(ans);
}

// This function returns true when a new Minute is Detected

bool NewMinute()
{
    static datetime LastMinute;
    datetime ThisMinute = TimeMinute( TimeGMT() );

    if( ThisMinute != LastMinute )
    {
        LastMinute = ThisMinute;
        return ( true );
    }
    else
        return ( false );
}

bool NewHour()
{
   static datetime LastHour;
   datetime ThisHour = TimeHour(TimeGMT());
   if( ThisHour != LastHour )
   {
      LastHour = ThisHour;
      return (true);
   }
   else
      return (false);
}

bool NewDay()
{
   static datetime LastDay;
   datetime ThisDay = TimeDay(TimeGMT());
   if( ThisDay != LastDay )
   {
      LastDay = ThisDay;
      return (true);
   }
   else
      return (false);
}

int TimeConvert( datetime time )
{
   int value = TimeHour(time)*100 + TimeMinute(time);
   return(value);
}

bool SessionClosed( string symbol, datetime timeNow )
{
   datetime openTime, closeTime;
   SymbolInfoSessionTrade(symbol,DayOfWeek(),0,openTime,closeTime);
   
   int current = TimeConvert(timeNow);
   int open = TimeConvert(openTime);
   int close = TimeConvert(closeTime);
      
   if( current < open || current > close)
   {
      return (true);
   }
   else
   {
      return(false);
   }
}

bool TradingClosed( string symbol, datetime timeNow )
{
   datetime openTime, closeTime;
   SymbolInfoSessionTrade(symbol,DayOfWeek(),0,openTime,closeTime);

   int current = TimeConvert(timeNow);   
   int open = TimeConvert(openTime);
   int close = TimeConvert(closeTime);
      
   if( current < open || current > close)
   {
      return (true);
   }
   else
   {
      return(false);
   }
}

datetime MarketOpenTime( string symbol )
{
   datetime openTime, closeTime;
   SymbolInfoSessionTrade(symbol,DayOfWeek(),0,openTime,closeTime);
   
   return( openTime );
}

datetime MarketCloseTime( string symbol )
{
   datetime openTime0, closeTime0, openTime1, closeTime1;
   if(SymbolInfoSessionTrade(symbol,DayOfWeek(),1,openTime1,closeTime1))
   {
      return(closeTime1);
   }
   
   SymbolInfoSessionTrade(symbol,DayOfWeek(),0,openTime0,closeTime0);
   return(closeTime0);
}

bool MarketClosingWindow( string symbol, datetime timeNow, int TimeLimit )
{
    int current = TimeConvert( timeNow );

    if( current >= ( TimeConvert(MarketCloseTime( symbol ) - TimeLimit * 60) ) && current <= TimeConvert(MarketCloseTime( symbol )) )
    {
        return( true );
    }
    return( false );
}

// This Function returns True when the Current Hour is equal to or between the Start and Finish times
bool TimeFilter(int Start,int Finish)
{
   bool response = false;
   int CurrentTime = TimeHour(TimeGMT());
   if( Start == 0 ) Start = 24; 
   if( Finish == 0 ) Finish = 24; 
   if( CurrentTime == 0 ) CurrentTime = 24;

   if ( ((Start < Finish) && ( (CurrentTime < Start) || (CurrentTime > Finish))) || ((Start > Finish) && ((CurrentTime < Start) && (CurrentTime > Finish))) )
   {
      response = false;
      return(response);
   }
   else
   {
      response = true;
      return(response);
   }   
}

bool IndexFilter( string symbol, int IndexPeriod, ENUM_TIMEFRAMES timeframe )
{
   double Index = iClose( symbol, timeframe, 1 );
   double IndexMA = iMA( symbol, timeframe,IndexPeriod,0,MODE_SMA,PRICE_CLOSE,1);
   if( Index >= IndexMA )
      return(true);
   else
      return(false);
}

//--- Is the Symbol in the Market watchlist
bool SymbolNameCheck( string symbol )
{
    for( int s = 0; s < SymbolsTotal( false ); s++ )
    {
        if( symbol == SymbolName( s, false ) )
            return( true );
    }

    return( false );
}

//--- Is there a disruption in the Data
bool StockSplitCheck( string symbol, int NumberOfBars )
{
   for( int i = 0; i < NumberOfBars; i++ )
   {
     double close0 = iClose( symbol, NULL, i );
     double open0 = iOpen( symbol, NULL, i );
     double open1 = iOpen( symbol, NULL, i + 1 );
   
     if( close0 == 0 || open0 == 0 || open1 == 0 )
         return( false );
   
     double R = close0 / open1;
     double R2 = open0 / open1;
   
     if( R > 1.49 || R < 0.67 || R2 > 1.49 || R2 < 0.67 )
         return( false );
   }
   
   return( true );
   }


/* //Not sure if this actually works anyway....
bool CurrentDailyCandle( string symbol )
{
    int DayOfMinute1 = TimeDay( iTime( symbol, PERIOD_M1, 1 ) );
    int DayOfDay0 = TimeDay( iTime( symbol, PERIOD_D1, 0 ) );

    if( DayOfMinute1 == DayOfDay0 )
        return( true );
    else
        return( false );
}

*/

bool ValidDateSequence( string symbol )
{
    int Day_0 = TimeDayOfYear( iTime( symbol, PERIOD_D1, 0 ) );
    int Day_1 = TimeDayOfYear( iTime( symbol, PERIOD_D1, 1 ) );
    int Shift = ( Day_0 - Day_1 );
    int DayofWeek = TimeDayOfWeek( iTime( symbol, PERIOD_D1, 0 ) );

    if( DayofWeek != 1 && Shift == 1 )
    {
        return( true );
    }

    if( DayofWeek == 1 && Shift == 3 )
    {
        return( true );
    }
    else
    {
        return( false );
    }
}

//--- Has the candle actually formed
bool ValidCandleCheck(string symbol, ENUM_TIMEFRAMES timeframe)
{
   bool response = false;
   double low = iLow(symbol,timeframe,0);
   double high = iHigh(symbol,timeframe,0);   
   if( MathAbs( high - low ) == 0 || low == 0 || high == 0 )
   {
      response = false;
      return(response);
   }
   else
   {
      response = true;
      return(response);
   }
}   

//--- Returns Current Profit from all Trades on the Symbol
double CurrentProfit(string symbol, int nMagic)
{
   double Profit = 0;
   for ( int i = OrdersTotal()-1 ; i>=0 ; i-- )
   {
      if( !OrderSelect(i,SELECT_BY_POS) ) continue;
      if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
      {
         Profit += OrderProfit();
      }   
   }
   return(Profit);
}

// This function returns the positon of the HHV of the close within the Array LookBack period
bool HHV_Filter( string symbol, ENUM_TIMEFRAMES timeframe, int HHV_LB, int ARRAY_LB )
{
    bool ans = false;
    
    int HHV_C = iHighest( symbol, timeframe, MODE_CLOSE, ARRAY_LB, 1 );

    if( HHV_C == -1 || HHV_C > HHV_LB )
    {
        ans = false;
        return( ans );
    }
    else
    {
        ans = true;
        return( ans );
    }
}

double customRSI(string symbol, ENUM_TIMEFRAMES timeframe, double rsiperiod, int index)
{
   int barcount = iBars(symbol,timeframe);
   if(barcount < 5)
   {
      Print("customRSI Fail Due Insufficient Bars ... ", symbol);
      return(-1);
   }

   double   lambda = 1 / rsiperiod;

   double   close[];
   double   gain = 0, 
            emaGain = 0,
            loss = 0, 
            emaLoss = 0;
   
   if( !CopyClose(symbol,timeframe,0,barcount,close) ) return (-1);
   
   for( int i = 1; i < barcount - index; i++ )
   {
      gain = MathMax( (close[i] - close[i-1]), 0 );
      loss = MathMax( (close[i-1] - close[i]), 0 );
      
      emaGain = lambda * gain + (1 - lambda) * emaGain;
      emaLoss = lambda * loss + (1 - lambda) * emaLoss;           
   }
   
   if( (emaGain+emaLoss) == 0 ) return(50);
   else
   return( 100 * emaGain / (emaGain + emaLoss) );
}



// This function will calculate the required value of Close[0] to give the rsiTarget value
double ReverseRSI(string symbol, ENUM_TIMEFRAMES timeframe, double rsiperiod, double rsitarget)
{    
   int barcount = iBars(symbol,timeframe);
   
   if(barcount < 5)
   {
      Print("ReverseRSI Fail Due Insufficient Bars ... ", symbol);
      return(-1);
   }
   
   if(rsiperiod == 0) return(-1);
   
   double   lambda = 1 / rsiperiod;

   double   close[];
   double   gain = 0, 
            emaGain = 0,
            loss = 0, 
            emaLoss = 0;
   
   if( !CopyClose(symbol,timeframe,0,barcount,close) ) return (-1);
   
   for( int i = 1; i < barcount - 1; i++ )
   {
      gain = MathMax( (close[i] - close[i-1]), 0 );
      loss = MathMax( (close[i-1] - close[i]), 0 );
      
      emaGain = lambda * gain + (1 - lambda) * emaGain;
      emaLoss = lambda * loss + (1 - lambda) * emaLoss;           
   }
   
   if( (emaGain + emaLoss) == 0 )return(-1);
   double rsi1 = 100 * emaGain / (emaGain + emaLoss);
   
   double answer = -1;
   if( rsitarget < rsi1 )
   {
      answer = close[barcount-2] - 100*(((rsiperiod-1)*emaGain)/rsitarget)+((rsiperiod-1)*emaGain)+((rsiperiod-1)*emaLoss);
   }    
   if( rsitarget >= rsi1 )
   {
      answer = close[barcount-2] + ((rsitarget/(100-rsitarget)*((rsiperiod-1)*emaLoss))-((rsiperiod-1)*emaGain)); 
   }
      
   return(answer);
}

// This function returns the boolean pass fail of an ATR Filter where if ATR1 >= ATR2 the function is true, else false
bool ATR_Filter( string symbol, ENUM_TIMEFRAMES timeframe, int P1, int P2 )
{
   double ATR1 = iATR( symbol,timeframe,P1,1 );
   double ATR2 = iATR( symbol,timeframe,P2,1 );
   
   if( ATR1 == 0 || ATR2 == 0 )
   {
      return(false);
   }
   
   if( ATR1 >= ATR2 )
   {
      return(true);
   }
   else
   {
      return(false);
   }   
}

// This function counts the number of different symbols that are open within a system
int CountOpenSymbols( int nOrderType, int nMagic )
{
    int TotalSymbols = 0;
    string strSymbol;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        if( i == 0 ) // There is only 1 Open Order ...
        {
            TotalSymbols += 1;
            break;
        }

        if( OrderMagicNumber() == nMagic && OrderType() == nOrderType )
        {
            strSymbol = OrderSymbol();
            {
                for( int j = i - 1 ; j >= 0 ; j-- )
                {
                    if( !OrderSelect( j, SELECT_BY_POS ) ) continue;

                    if( OrderMagicNumber() == nMagic && OrderType() == nOrderType )
                        if( OrderSymbol() == strSymbol )
                            break;

                    if( j == 0 )
                        TotalSymbols++;
                }
            }
        }
    }

    return( TotalSymbols );
}

//--- Returns the Lowest Open Price on the Symbol
double LowestOpenPrice(string symbol, int nOrderType, int nMagic)
{
   double LowestPrice = 10000000000000;
   for( int i=OrdersTotal()-1 ; i>=0 ; i-- )
   {
      if( !OrderSelect(i,SELECT_BY_POS) ) continue;
      {
         if( OrderSymbol() == symbol && OrderType() == nOrderType && OrderMagicNumber() == nMagic )
         {
           // if ( LowestPrice == -1 )
           // {
           //    LowestPrice = OrderOpenPrice();
           //    continue;
           // }
            
            if( OrderOpenPrice() < LowestPrice )
            {
               LowestPrice = OrderOpenPrice();
               continue;
            }            
         }   
      }   
   }
   return(LowestPrice);
}

//--- Returns the Highest Open Price on the Symbol
double HighestOpenPrice(string symbol, int nOrderType, int nMagic)
{
   static double HighestPrice = 0;
   for( int i=OrdersTotal()-1 ; i>=0 ; i-- )
   {
      if( !OrderSelect(i,SELECT_BY_POS)) continue;
      {
         if( OrderSymbol() == symbol && OrderType() == nOrderType && OrderMagicNumber() == nMagic )
         {
            if( OrderOpenPrice() > HighestPrice )
            {
               HighestPrice = OrderOpenPrice();
            }           
         }   
      }   
   }
   return(HighestPrice);
}

// This function returns the number of open orders matching the symbol and system magic number
int CountExpertOrders( string symbol, int nOrderType, int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        if( OrderType() == nOrderType && OrderMagicNumber() == nMagic && OrderSymbol() == symbol )
        {
            nOrderCount++;
        }
    }

    return( nOrderCount );
}

// This function returns the number of open orders matching system magic number
int CountSystemOrdersLong( int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        if( OrderSymbol() != Symbol()) continue;
        if( OrderMagicNumber() != nMagic ) continue;
        if( OrderType() != OP_BUY) continue;
        nOrderCount++;
    }

    return( nOrderCount );
}

// This function returns the number of open orders matching system magic number
int CountSystemOrdersShort( int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        if( OrderSymbol() != Symbol()) continue;
        if( OrderMagicNumber() != nMagic ) continue;
        if( OrderType() != OP_SELL) continue;
        nOrderCount++;
    }

    return( nOrderCount );
}

// This function returns the number of open orders matching system magic number
int CountSystemOrders( int nOrderType, int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        if( OrderType() == nOrderType && OrderMagicNumber() == nMagic )
        {
            nOrderCount++;
        }
    }

    return( nOrderCount );
}

// This function returns the number of open orders matching system magic number and base currency ie USD, EUR, UK etc
int CountSystemOrdersUS( int nOrderType, int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        
        string symbolBase = SymbolInfoString(OrderSymbol(),SYMBOL_CURRENCY_BASE);

        if( OrderType() == nOrderType && OrderMagicNumber() == nMagic && symbolBase == "USD")
        {
            nOrderCount++;
        }
    }

    return( nOrderCount );
}

int CountSystemOrdersGBP( int nOrderType, int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        
        string symbolBase = SymbolInfoString(OrderSymbol(),SYMBOL_CURRENCY_BASE);

        if( OrderType() == nOrderType && OrderMagicNumber() == nMagic && symbolBase == "GBP")
        {
            nOrderCount++;
        }
    }

    return( nOrderCount );
}

int CountSystemOrdersEUR( int nOrderType, int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        
        string symbolBase = SymbolInfoString(OrderSymbol(),SYMBOL_CURRENCY_BASE);

        if( OrderType() == nOrderType && OrderMagicNumber() == nMagic && symbolBase == "EUR")
        {
            nOrderCount++;
        }
    }

    return( nOrderCount );
}

int CountSystemOrdersOthers( int nOrderType, int nMagic )
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        
        string symbolBase = SymbolInfoString(OrderSymbol(),SYMBOL_CURRENCY_BASE);

        if( OrderType() == nOrderType && OrderMagicNumber() == nMagic && symbolBase != "USD" && symbolBase != "GBP" && symbolBase != "EUR")
        {
            nOrderCount++;
        }
    }

    return( nOrderCount );
}

// This function returns the total number of open orders.
int CountGlobalOrders()
{
    int nOrderCount = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        if( OrderType() == OP_BUY || OrderType() == OP_SELL )
        {
            nOrderCount++;
        }
    }

    return( nOrderCount );
}

// This function returns the number of Bars Since the selected order was entered
int BarsSinceEntry( string symbol, ENUM_TIMEFRAMES timeframe, int nMagic )
{
    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
        {
            return( iBarShift( symbol, timeframe, OrderOpenTime() ) );
        }
    }

    return( 0 );
}

// This function returns the OrderType of the last placed Order Plus 1 ie ... Buy =1 Sell=2 Blimit=3 Slimit=4 Bstop=5 Sstop=6
int LastOpenTrade(string symbol, int nMagic)
{
   int last_trade = 0;
   if(OrdersTotal() != 0)
   {
      if(OrderSelect(last_trade-1,SELECT_BY_POS,MODE_TRADES)==true)
      {   
        if(OrderSymbol() == symbol && OrderMagicNumber() == nMagic)
        {
          return(OrderType()+1);
        }
      }
   }
   return(EMPTY_VALUE);
}

// Function returns the LLV of the Close given a start bar and a lookback
double LowestLowClose(string symbol, ENUM_TIMEFRAMES timeframe, int LookBack, int Start)
{
   int shift = iLowest(symbol,timeframe,MODE_CLOSE,LookBack,Start);
   double LLV = iClose(symbol,timeframe,shift);
   return(LLV);
}

//Function returns true for a cross up and false for a cross down and EMPTY VALUE for default
int Cross(double fast1, double slow1, double fast2, double slow2)
{
   if(fast1>slow1 && fast2<=slow2)
      return(1);
   else if(fast1<slow1 && fast2>=slow2)
      return(-1);
   else
      return(0);
}

//+------------------------------------------------------------------+
//| System History Reports to Excel                        |
//+------------------------------------------------------------------+

void MATLAB2015( string eaName = "", int nMagic = 0, datetime startDate = 0 )
{
   double count = 0;
   double delta = 0;
   double posValue = 0;
   double brokerFees = 0;
   double netDelta = 0;
   double netProfit = 0;
   string fileName;
   
   if( nMagic != 0)
   {
      fileName = StringConcatenate(AccountCompany()," - ",AccountNumber(),"\\",eaName," - ",nMagic,"\\tradeHistory.csv");
   }
   else
   {
      fileName = StringConcatenate(AccountCompany()," - ",AccountNumber(),"\\Complete History\\allTradeHistory.csv");
   }
   
   int fileHandle = FileOpen(fileName,FILE_CSV|FILE_WRITE,',');

   FileWrite(fileHandle,"Num","Magic","Symbol","exDate","Shares","posValue","Price","exPrice","brokerFees","Delta","netProfit");
   for( int i = 0; i <= OrdersHistoryTotal() - 1; i++ )
   {     
      if ( !OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) ) continue;
      if ( OrderSymbol() == "" || OrderOpenPrice() == 0 ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      if ( OrderType() != OP_BUY && OrderType() != OP_SELL ) continue;
      if ( nMagic != 0 && OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
         
      count += 1;
      
      delta = ( OrderClosePrice() - OrderOpenPrice() ) / OrderOpenPrice();
        
      brokerFees = ( OrderCommission() + OrderSwap() );
     
      if(delta == 0){ delta = 0.0000000001; }       
      posValue = OrderProfit() / delta;
      
      netProfit = ( OrderProfit() + OrderCommission() + OrderSwap() );
      
      if( posValue == 0)
      {
         netDelta = 0;
      }
      else
      {
         netDelta = netProfit / posValue ;
      }
     
      FileWrite(fileHandle,count,OrderMagicNumber(),OrderSymbol(),TimeToStr(OrderCloseTime(),TIME_DATE),OrderLots(),posValue,OrderOpenPrice(),OrderClosePrice(),brokerFees,netDelta,netProfit);
   }
   FileClose(fileHandle);
}

void BrokersStatement()
{
   double posValue = 0;
   double netDelta = 0;
   double brokerFees = 0;
   double tradeValue = 0;
   double netProfit = 0;
   double fixedProfit = 0;
   
   datetime current = TimeCurrent();
   int month = TimeMonth(current);
   int year = TimeYear(current);

   string fileName = StringConcatenate(AccountCompany()," - ",AccountNumber(),"\\Complete History\\Broker Statement ",month,"-",year,".csv");
   int fileHandle = FileOpen(fileName,FILE_CSV|FILE_WRITE,',');

   FileWrite(fileHandle, "eaName","magicNumber","Symol","Date","Ex.Date","Shares","Price","Ex.Price","GrossProfit","Commission","Swap","netProfit");
   
   for( int i = 0; i <= OrdersHistoryTotal() - 1; i++ )
   {     
      if ( !OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) ) continue;
        
      brokerFees = ( OrderCommission() + OrderSwap() );
      
      netProfit = ( OrderProfit() + OrderCommission() + OrderSwap() );
     
      FileWrite( fileHandle, OrderComment(), OrderMagicNumber(), OrderSymbol(), TimeToStr(OrderOpenTime(),TIME_DATE), TimeToStr(OrderCloseTime(),TIME_DATE), OrderLots(), OrderOpenPrice(), OrderClosePrice(), OrderProfit(), OrderCommission(), OrderSwap(), netProfit );
   }
   FileClose( fileHandle );
}

//+------------------------------------------------------------------+
//| Export Brokers Data to ASCII Format                              |
//+------------------------------------------------------------------+

void Write_ASCII(string symbol, string Folder, ENUM_TIMEFRAMES timeframe, datetime startDate) 
{
   int handle = FileOpen("ASCII_DataExport\\" + Folder +"\\" + EnumToString(timeframe) + "\\" + symbol + ".txt", FILE_CSV|FILE_WRITE, ',');

   if ( handle > 0 ) 
   {
      FileWrite(handle,"SYMBOL","DATE","TIME","OPEN","HIGH","LOW","CLOSE","VOLUME","SPREAD");
      for(int Bar = iBars(symbol,timeframe)-1; Bar >= 0; Bar --)
      {
         double ask, bid, spread = 0;
         if ( DateCheck(startDate,iTime(symbol,timeframe,Bar)) == false ) continue;
         ask = MarketInfo( symbol, MODE_ASK );
         bid = MarketInfo( symbol, MODE_BID );
         if ( ask == 0 || bid == 0 )
         {
            spread = 0;
         }
         else
         {
            spread = ( ask - bid ) / ask;
         }
         FileWrite( handle, symbol, TimeToStr(iTime(symbol,timeframe,Bar),TIME_DATE), TimeToStr(iTime(symbol,timeframe,Bar),TIME_SECONDS), iOpen(symbol,timeframe,Bar), iHigh(symbol,timeframe,Bar), iLow(symbol,timeframe,Bar), iClose(symbol,timeframe,Bar),iVolume(symbol,timeframe,Bar),DoubleToString(spread,8) );
      }
      FileClose( handle );
   }
}

void Write_ASCII_ALL( ENUM_TIMEFRAMES timeframe, datetime startDate) 
{
   int handle = FileOpen("ASCII_DataExport\\" + EnumToString(timeframe) + ".csv", FILE_CSV|FILE_WRITE, ',');

   if ( handle > 0 ) 
   {
      FileWrite(handle,"SYMBOL","DATE","TIME","OPEN","HIGH","LOW","CLOSE","VOLUME","SPREAD");
      for(int i = 0; i<SymbolsTotal(false); i++)
      {
         string symbol = SymbolName(i,false);      
         if( SymbolNameCheck( symbol ) == false ) continue;
         
         for(int Bar = iBars(symbol,timeframe)-1; Bar >= 0; Bar --)
         {
            double ask, bid, spread = 0;
            if ( DateCheck(startDate,iTime(symbol,timeframe,Bar)) == false ) continue;
            ask = MarketInfo( symbol, MODE_ASK );
            bid = MarketInfo( symbol, MODE_BID );
            if ( ask == 0 || bid == 0 )
            {
               spread = 0;
            }
            else
            {
               spread = ( ask - bid ) / ask;
            }
            FileWrite( handle, symbol, TimeToStr(iTime(symbol,timeframe,Bar),TIME_DATE), TimeToStr(iTime(symbol,timeframe,Bar),TIME_SECONDS), iOpen(symbol,timeframe,Bar), iHigh(symbol,timeframe,Bar), iLow(symbol,timeframe,Bar), iClose(symbol,timeframe,Bar),iVolume(symbol,timeframe,Bar),DoubleToString(spread,8) );
         }
      }
      FileClose( handle );
   }
}

//+------------------------------------------------------------------+
//| Basic Trade Functions with Error Analysis                        |
//+------------------------------------------------------------------+

// This function returns true if the EA closed a trade on this bar
bool ExitBar( string symbol, ENUM_TIMEFRAMES timeframe, int nMagic )
{
    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;

        if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
        {
            if( iBarShift( symbol, timeframe, OrderCloseTime() ) == 0 )
            {
                return( true );
            }
        }
    }
    return( false );
}  
 
double SymbolToUSD(string symbol)
{
    string BASE = SymbolInfoString( symbol, SYMBOL_CURRENCY_BASE );
    double BASEUSD = iClose( SymbolInfoString( symbol, SYMBOL_CURRENCY_BASE ) + "USD", PERIOD_D1, 0 );
    double USDBASE = iClose( "USD" + SymbolInfoString( symbol, SYMBOL_CURRENCY_BASE ), PERIOD_D1, 0 );
    
    double M = 0;

    if(BASE == "USD")
    {
      return( 1 );
    }
    
    if( BASEUSD != 0 || USDBASE != -1 )
    {
        if( BASEUSD != -1 && BASEUSD != 0 )
        {
            return( 1 / BASEUSD );
        }

        if( USDBASE != 0 )
        {
            return( USDBASE );
        }
    }

    return( 0 );
}

double USDtoACCT()
{
   string BASE = AccountInfoString(ACCOUNT_CURRENCY);
   
   // Base is either USD, EUR, GBP, AUD 
   
   if(BASE == "USD")
   {
      return(1);
   }
   
   if(BASE == "AUD")
   {
      return(SymbolInfoDouble("AUDUSD", SYMBOL_BID));
   }
   
   if(BASE == "EUR")
   {
      return(SymbolInfoDouble( "EURUSD", SYMBOL_BID));
   }
   
   if(BASE == "GBP")
   {
      return(SymbolInfoDouble( "GBPUSD", SYMBOL_BID));
   }
   
   return(0);     
}

double CurrencyConverter(string symbol, bool GBPinPence)
{
   return( SymbolToUSD(symbol) * USDtoACCT() / isPence(symbol, GBPinPence) );
}

double isPence(string symbol, bool pence)
{
   if( SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE) == "GBP" && pence == true)
   {
      return(0.01);
   }
   else
   {
      return(1);
   }
}


bool DateCheck(datetime startDate, datetime objectDate)
{
   
   if( objectDate > startDate)
   {
      return(true);
   }
   else
   {
      return(false);
   }
}
   
double MoneyManagement( double MM, double AA )
{
    double Balance = AccountBalance();
    return( AA * MM * Balance );
}

double PositionSize( string symbol, double Amount, bool GBPinPence)
{
    double Exchange = 0;
    Exchange = CurrencyConverter( symbol, GBPinPence );
    double Price = iClose( symbol, NULL, 0 );
    double sharesPerLot = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);
    double minVolume = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
    double maxVolume = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
    double minVolumeStep = SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);

    if( Exchange == 0 || Price == 0 || sharesPerLot == 0 || minVolumeStep == 0 )
    {
        return( 0 );
    }
      
    double nShares = ( Exchange * Amount ) / ( Price * sharesPerLot);
    double LotSize = MathRound( nShares / minVolumeStep ) * minVolumeStep;

    if( LotSize < minVolume )
    {
        LotSize = minVolume;
    }
    
    if( LotSize > maxVolume )
    {
        LotSize = maxVolume;
    }   

    return( LotSize );
}

double ShareValue( string symbol, bool GBPinPence = false )
{
    double Exchange = 0;
    Exchange = CurrencyConverter( symbol, GBPinPence );

    if( Exchange == 0 )
    {
        Print("ShareValue not possible due currency conversion failure ... ",symbol);
        return( 0 );
    }

    return( SymbolInfoDouble( symbol,SYMBOL_BID ) / Exchange );
}


void EnterLong( string symbol, double Lots, double Price, int Slippage, double StopLossPct, double TakeProfitPct, int nMagic, string Label )
{
    static double stoploss, takeprofit, ticksize;
    ticksize = MarketInfo( symbol, MODE_TICKSIZE );
    int digits = (int)MarketInfo( symbol, MODE_DIGITS );

    if( StopLossPct != 0 )
    {
        stoploss = NormalizeDouble( MathCeil( ( ( Price * ( 1 - StopLossPct * 0.01 ) ) / ticksize ) ) * ticksize, digits );
    }

    if( TakeProfitPct != 0 )
    {
        takeprofit = NormalizeDouble( MathCeil( ( ( Price * ( 1 + TakeProfitPct * 0.01 ) ) / ticksize ) ) * ticksize, digits );
    }

    RefreshRates();

    if( !OrderSend( symbol, OP_BUY, Lots, Price, Slippage, stoploss, takeprofit, Label, nMagic, 0, NULL ) )
    {
        ErrorReport( GetLastError() );
    }
}


void ExitLong( string symbol, double Price, int Slippage, int nMagic, color CLR )
{
    for( int i = OrdersTotal() - 1; i >= 0 ; i-- )
    {
        if( ! OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) ) continue;

        if( OrderSymbol() == symbol && OrderType() == OP_BUY && OrderMagicNumber() == nMagic )
        {
            if( ! OrderClose( OrderTicket(), OrderLots(), Price, Slippage, CLR ) )
                Print( "Order Close Failed, order number: ", OrderTicket(), " Error ", GetLastError() );
        }
    }
}

void EnterShort(string symbol, double Lots, double Price, int Slippage, double StopLossPct, double TakeProfitPct, int nMagic, string Label)
{
   static double stoploss,takeprofit,ticksize;
   ticksize = MarketInfo(symbol,MODE_TICKSIZE);
   int digits = (int)MarketInfo( symbol, MODE_DIGITS );
   
   if( StopLossPct != 0 ) 
   {
      stoploss = NormalizeDouble(MathCeil(((Price*(1+StopLossPct*0.01))/ticksize))*ticksize,digits);
   }
   
   if( TakeProfitPct != 0 ) 
   {
      takeprofit = NormalizeDouble(MathCeil(((Price*(1-TakeProfitPct*0.01))/ticksize))*ticksize,digits);
   }
   
   RefreshRates();
   
   if(!OrderSend(symbol,OP_SELL,Lots,Price,Slippage,stoploss,takeprofit,Label,nMagic,0,NULL)) 
   {
      ErrorReport(GetLastError());
   }
}

void ExitShort(string symbol, double Price, int Slippage, int nMagic)
{  
   for(int i=OrdersTotal() -1; i>=0 ; i--)
   {
      if( ! OrderSelect(i,SELECT_BY_POS,MODE_TRADES) ) continue;
      if( OrderSymbol() == symbol && OrderType()==OP_SELL && OrderMagicNumber()==nMagic )
      {
         if( !OrderClose(OrderTicket(),OrderLots(),Price,Slippage,NULL))
            Print("Order Close Failed, order number: ",OrderTicket()," Error ", GetLastError());
      }
   }
}

void ApplyTakeProfit( string symbol, double TakeProfitPct, int nMagic )
{
    double takeprofit = 0;
    double ticksize = SymbolInfoDouble( symbol, SYMBOL_TRADE_TICK_SIZE );
    int digits = (int)MarketInfo( symbol, MODE_DIGITS );

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        if( OrderMagicNumber() != nMagic ) continue;
        {
            if( OrderSymbol() == symbol )
            {
                if( OrderType() == OP_BUY )
                {
                    takeprofit = MathRound( OrderOpenPrice() * ( 1 + ( TakeProfitPct * 0.01 ) ) / ticksize ) * ticksize;
                }

                if( OrderType() == OP_SELL )
                {
                    takeprofit = MathRound( OrderOpenPrice() * ( 1 - ( TakeProfitPct * 0.01 ) ) / ticksize ) * ticksize;
                }
            }

            if( OrderTakeProfit() != takeprofit && takeprofit != 0 && OrderSymbol() == symbol )
            {
                if( !OrderModify( OrderTicket(), OrderOpenPrice(), OrderStopLoss(), takeprofit, 0 ) )
                    Print( "Order Modify Failed, order number: ", OrderTicket(), " Error ", GetLastError() );
            }
        }
    }
}

void ApplyStopLoss( string symbol, double StopLossPct, int nMagic )
{
    double stoploss = 0;
    double ticksize = SymbolInfoDouble( symbol, SYMBOL_TRADE_TICK_SIZE );
    int digits = (int)MarketInfo( symbol, MODE_DIGITS );

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        {
            if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
            {
                if( OrderType() == OP_BUY )
                {
                    stoploss = MathRound( OrderOpenPrice() * ( 1 - ( StopLossPct * 0.01 ) ) / ticksize ) * ticksize;
                }

                if( OrderType() == OP_SELL )
                {
                    stoploss = MathRound( OrderOpenPrice() * ( 1 + ( StopLossPct * 0.01 ) ) / ticksize ) * ticksize;
                }
            }

            if( OrderStopLoss() != stoploss && stoploss != 0 && OrderSymbol() == symbol )
            {
                if( !OrderModify( OrderTicket(), OrderOpenPrice(), stoploss, OrderTakeProfit(), 0 ) )
                    Print( "Order Modify Failed, order number: ", OrderTicket(), " Error ", GetLastError() );
            }
        }
    }
}

void ModifyPosition( string symbol, double TakeProfitPct, double StopLossPct, int nMagic )
{
    double stoploss = 0;
    double takeprofit = 0;
    double ticksize = SymbolInfoDouble( symbol, SYMBOL_TRADE_TICK_SIZE );
    int digits = (int)MarketInfo( symbol, MODE_DIGITS );

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;
        {
            if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
            {
                if( OrderType() == OP_BUY )
                {
                    if( TakeProfitPct != 0 )
                    {
                        takeprofit = MathRound( OrderOpenPrice() * ( 1 + ( TakeProfitPct * 0.01 ) ) / ticksize ) * ticksize;
                    }
                    if( StopLossPct != 0 )
                    {
                        stoploss = MathRound( OrderOpenPrice() * ( 1 - ( StopLossPct * 0.01 ) ) / ticksize ) * ticksize;
                    }
                }

                if( OrderType() == OP_SELL )
                {
                    if( TakeProfitPct != 0 )
                    {
                        takeprofit = MathRound( OrderOpenPrice() * ( 1 - ( TakeProfitPct * 0.01 ) ) / ticksize ) * ticksize;
                    }
                    if( StopLossPct != 0 )
                    {
                        stoploss = MathRound( OrderOpenPrice() * ( 1 + ( StopLossPct * 0.01 ) ) / ticksize ) * ticksize;
                    }
                }
            }

            if( OrderTakeProfit() != takeprofit || OrderStopLoss() != stoploss)
            {
                if( !OrderModify( OrderTicket(), OrderOpenPrice(), stoploss, takeprofit, 0 ) )
                    Print( "Order Modify Failed, order number: ", OrderTicket(), " Error ", GetLastError() );
            }
        }
    }
}

double OpenPrice( string symbol, int nMagic )
{
    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        {
            if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
            {
                return( OrderOpenPrice() );
            }
        }
    }

    return( 0 );
}

double TakeProfitPrice( string symbol, double TakeProfitPct, int nMagic )
{
    double takeprofit = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        {
            if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
            {
                if( OrderType() == OP_BUY )
                {
                    takeprofit = OrderOpenPrice() * ( 1 + ( TakeProfitPct * 0.01 ) );
                }

                if( OrderType() == OP_SELL )
                {
                    takeprofit = OrderOpenPrice() * ( 1 - ( TakeProfitPct * 0.01 ) );
                }
            }
        }
    }

    return( takeprofit );
}

double StopLossPrice( string symbol, double StopLossPct, int nMagic )
{
    double stoploss = 0;

    for( int i = OrdersTotal() - 1 ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS ) ) continue;

        {
            if( OrderSymbol() == symbol && OrderMagicNumber() == nMagic )
            {
                if( OrderType() == OP_BUY )
                {
                    stoploss = OrderOpenPrice() * ( 1 - ( StopLossPct * 0.01 ) );
                }

                if( OrderType() == OP_SELL )
                {
                    stoploss = OrderOpenPrice() * ( 1 + ( StopLossPct * 0.01 ) );
                }
            }
        }
    }

    return( stoploss );
}

//+------------------------------------------------------------------+
//| System Status Functions                                          |
//+------------------------------------------------------------------+

double NetDelta()
{
   double delta = 0;
   double brokerFees = 0;
   double posValue = 0;
   double netProfit = 0;
   double netDelta = 0;

   delta = ( OrderClosePrice() - OrderOpenPrice() ) / OrderOpenPrice();
     
   brokerFees = ( OrderCommission() + OrderSwap() );
  
   if(delta == 0)
   {
      delta = 0.00000000001;
   }       
   posValue = OrderProfit() / delta;
   
   netProfit = ( OrderProfit() + OrderCommission() + OrderSwap() );
   
   if( posValue == 0)
   {
      netDelta = 0;
   }
   else
   {
      netDelta = netProfit / posValue ;
   }
   
   return(netDelta);
}

double Exposure( bool GBPinPence = false)
{
    double Exp = 0;

    for( int i = OrdersTotal() - 1; i >= 0; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) ) continue;

        if( CurrencyConverter( OrderSymbol(), GBPinPence ) == 0 ) return( 0 );

        Exp += OrderLots() * OrderOpenPrice() / CurrencyConverter( OrderSymbol(), GBPinPence );
    }

    return( Exp );
}

double SystemExposure( int nMagic, bool GBPinPence = false )
{
    double Exp = 0;

    for( int i = OrdersTotal() - 1; i >= 0; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) ) continue;

        if( CurrencyConverter( OrderSymbol(), GBPinPence ) == 0 ) return( 0 );

        if( OrderMagicNumber() == nMagic )
        {
            Exp += OrderLots() * OrderOpenPrice() / CurrencyConverter( OrderSymbol(), GBPinPence );
        }
    }

    return( Exp );
}

int TotalTradesHistory( int nMagic, datetime startDate )
{
    int nTrades = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
 
        nTrades += 1;
    }

    return( nTrades );
}

double MDD9510K( double mu1, double sDev, int tpy, int ForcastHorizon, double ConfidenceLevel, int Runs)
{
   //create TWR and MDD Arrays
   double MDD[];
   ArrayResize(MDD,Runs,0);
   
      for( int a = 0 ; a < Runs ; a++ )
      {
         // Set Variables for MC Run
         double equity = 0;
         double maxEquity = 0;
         double drawDown = 0;
         double maxDrawDown = 0;
         
         double randomTrade = 0;
         double thisTrade = 0;
         
         for( int x = 0; x < ForcastHorizon*tpy; x++ )
         {
            thisTrade = rand_normal(100*mu1,100*sDev);
            equity = equity + thisTrade;
            maxEquity = MathMax(equity,maxEquity);
            drawDown = maxEquity - equity;
            maxDrawDown = MathMax(drawDown,maxDrawDown);      
         }          
         MDD[a] = maxDrawDown;        
      }
      
      ArraySort(MDD);
      
      int P95 = (int)MathFloor(ConfidenceLevel * Runs);    
      return(MDD[P95]);
       
}       
 
double twoTailedTTest( double m1, double m2, double s1, double s2, double n1, double n2)
{

   if( n1 == 0 || n2 == 0 )
      return(0);
   double num = m1-m2;
   double denom = sqrt( s1*s1/n1 + s2*s2/n2 );
   
   if( denom == 0 )
      return(0);
   else
      return(num / denom);
}

int ErrorReport( int Error )
{
    switch( Error )
    {
            //Non Critical Errors
        case 4:
        {
            Alert( "Trade server is busy. Trying once again.." );
            Sleep( 3000 );                                              // Simple Solution
            return( 1 );
        }                                                           // Exit the function

        case 135:
        {
            Alert( "Price changed. Trying once again.." );
            RefreshRates();
            return( 1 );
        }

        case 136:
        {
            Alert( "No Prices. Waiting for a new tick.." );

            while( RefreshRates() == false )                            //Till a new tick
                Sleep( 1 );                                              //pause in Loop

            return( 1 );
        }

        case 137:
        {
            Alert( "Broker is Busy. Trying once again.." );
            Sleep( 3000 );
            return( 1 );
        }

        case 146:
        {
            Alert( "Trading System is Busy. Trying once again.." );
            Sleep( 500 );
            return( 1 );
        }

        // Critical Errors
        case 2:
        {
            Alert( "Common Error." );                                   // Terminate the functin
            Sleep( 3000 );
            return( 1 );
        }                                                           // Exit the function

        case 5:
        {
            Alert( "Old Terminal Version." );
            return( 0 );
        }

        case 64:
        {
            Alert( "Account Blocked." );
            return( 0 );
        }

        case 133:
        {
            Alert( "Trading Forbidden." );
            return( 0 );
        }

        case 134:
        {
            Alert( "Not Enough Money to Execute Operation" );
            return( 0 );
        }
    }

    return( 0 );
}

double Spread (string symbol)
{
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   
   if( bid != 0)
   {
      return( (ask - bid) / bid );
   }
   else
   {
      return (1);
   }
}

double MoneyManagement( double MM )
{
    double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
    return( MM * Balance );
}

string visualScore( double score )
{
   if( score < 0.05 ) return(" |------------------- " );
   if( score < 0.10 ) return(" -|------------------ " );
   if( score < 0.15 ) return(" --|----------------- " );
   if( score < 0.20 ) return(" ---|---------------- " );
   if( score < 0.25 ) return(" ----|--------------- " );
   if( score < 0.30 ) return(" -----|-------------- " );
   if( score < 0.35 ) return(" ------|------------- " );
   if( score < 0.40 ) return(" -------|------------ " );
   if( score < 0.45 ) return(" --------|----------- " );
   if( score < 0.50 ) return(" ---------|---------- " );
   if( score < 0.55 ) return(" ----------|--------- " );
   if( score < 0.60 ) return(" -----------|-------- " );
   if( score < 0.65 ) return(" ------------|------- " );
   if( score < 0.70 ) return(" -------------|------ " );
   if( score < 0.75 ) return(" --------------|----- " );
   if( score < 0.80 ) return(" ---------------|---- " );
   if( score < 0.85 ) return(" ----------------|--- " );
   if( score < 0.90 ) return(" -----------------|-- " );
   if( score < 0.95 ) return(" ------------------|- " );
   else               return(" -------------------| " );
}

double rand_normal(double mean, double stddev)
{//Box muller method
    static double n2 = 0.0;
    static int n2_cached = 0;
    double RAND_MAX = 32767.0;
    if (!n2_cached)
    {
        double x, y, r;
        do
        {
            x = 2.0*rand()/RAND_MAX - 1;
            y = 2.0*rand()/RAND_MAX - 1;

            r = x*x + y*y;
        }
        while (r == 0.0 || r > 1.0);
        {
            double d = sqrt(-2.0*log(r)/r);
            double n1 = x*d;
            n2 = y*d;
            double result = n1*stddev + mean;
            n2_cached = 1;
            return result;
        }
    }
    else
    {
        n2_cached = 0;
        return n2*stddev + mean;
    }
}

//+------------------------------------------------------------------+
//| Dormant Functions                                                |
//+------------------------------------------------------------------+


/*double CurrencyConverter(string symbol)
{   
   string BASE = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);

   if(BASE == "USD")
   {
      return(1);
   }
   
   if(BASE == "GBP")
   {
      if( iClose("GBPUSD",PERIOD_D1,1) != 0 )
         return(100/iClose("GBPUSD",PERIOD_D1,1));
      else
         return(0);
   }
   
   if(BASE == "EUR")
   {
      if( iClose("EURUSD",PERIOD_D1,1) != 0 )
         return(1/iClose("EURUSD",NULL,1));
      else
         return(0);
   }

   if(BASE == "AUD")
   {
      if( iClose("AUDUSD",PERIOD_D1,1) != 0 )
         return(1/iClose("AUDUSD",NULL,1));
      else
         return(0);
   }  

   if(BASE == "JPY")
   {
      return(iClose("USDJPY",PERIOD_D1,1));
   }   
    
   if(BASE == "CAD")
   {
      return(iClose("USDCAD",PERIOD_D1,1));
   }  

   if(BASE == "CHF")
   {
      return(iClose("USDCHF",PERIOD_D1,1));
   }

   if(BASE == "PLN")
   {
      return(iClose("USDPLN",PERIOD_D1,1));
   }  

   if(BASE == "NOK")
   {
      return(iClose("USDNOK",PERIOD_D1,1));
   }   
    
   if(BASE == "HKD")
   {
      return(iClose("USDHKD",PERIOD_D1,1));
   }
   
   if(BASE == "SEK")
   {
      return(iClose("USDSEK",PERIOD_D1,1));
   }
   
   if(BASE == "HUF")
   {
      return(iClose("USDHUF",PERIOD_D1,1));
   }   
   
   return(0);   
}

/*
double SystemProfit( int nMagic, datetime startDate )
{
    double TotalProfit = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
        
        TotalProfit += ( OrderProfit() + OrderCommission() + OrderSwap() );
    }

    return( TotalProfit );
}

double StartBalance( datetime startDate )
{
    double TotalProfit = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
        
        TotalProfit += ( OrderProfit() + OrderCommission() + OrderSwap() );
    }

    return( AccountBalance() - TotalProfit );
}

double SystemProfitPct( int nMagic, datetime startDate )
{
    double TotalProfit = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
        
        TotalProfit += ( OrderProfit() + OrderCommission() + OrderSwap() );
    }

    return( 100 * ( TotalProfit / StartBalance(startDate) ) );
}

double SystemCAR( int nMagic, datetime startDate )
{
   double TPY = SystemTPY( nMagic, startDate );
   double TotalTrades = TotalTradesHistory( nMagic, startDate );
   double TWR = SystemProfitPct( nMagic, startDate )/100 + 1;

   double CAR = 100 * ( exp( log(TWR) / (TotalTrades/TPY) ) - 1 );
   
   return(CAR);
}

double SystemAccuracy( int nMagic, datetime startDate )
{
    double Wins = 0,
           nTrades = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;

        if( NetDelta() >= 0 )
        {
            Wins += 1;
        }

        nTrades += 1;
    }

    if( nTrades == 0 )
        return( 0 );
    else
        return( Wins / nTrades * 100 );
}

double SystemPayoffRatio( int nMagic, datetime startDate )
{
    double NumWins = 0,
           NumLoss = 0,
           AvgWin = 0,
           AvgLoss = 0,
           TotalWins = 0,
           TotalLoss = 0,
           Ratio = 0,
           Accuracy = 0,
           delta = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
        
        delta = NetDelta();

        if( delta >= 0 )
        {
            NumWins += 1;
            TotalWins += delta;
        }
        else
        {
            NumLoss += 1;
            TotalLoss += -delta;
        }
    }

    if( NumLoss == 0 || NumWins == 0 ) return( 0 );

    AvgWin = TotalWins / NumWins;
    AvgLoss = TotalLoss / NumLoss;
    Accuracy = NumWins / ( NumWins + NumLoss );
    Ratio = AvgWin / AvgLoss;
    return( Ratio );
}

double SystemAverageTrade( int nMagic, datetime startDate )
{
    double nTrades = 0,
           totalProfit = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;

        nTrades += 1;
        totalProfit += NetDelta();
    }

    if( nTrades == 0 || totalProfit == 0 ) return( 0 );

    return( totalProfit / nTrades );
}

double SystemTPY( int nMagic, datetime startDate )
{
    datetime   firstTradeDate = TimeCurrent();
    
    double     nTrades = 0,
               years = 0,
               days = 0,
               timeDiff;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
        
        
        if( OrderCloseTime() < firstTradeDate ) 
        {
            firstTradeDate = OrderCloseTime();
        }
        
        nTrades += 1;

    }
    
    years = TimeYear(TimeCurrent()) - TimeYear(firstTradeDate);
    days = TimeDayOfYear(TimeCurrent()) - TimeDayOfYear(firstTradeDate);
    
    timeDiff = 365*years + days;
    
    if( nTrades == 0 || timeDiff == 0 ) return( 0 );
    
    double TPY = nTrades / timeDiff * 365;

    return( TPY );
}

double SystemExpectancy( int nMagic, datetime startDate )
{
    double NumWins = 0,
           NumLoss = 0,
           AvgWin = 0,
           AvgLoss = 0,
           TotalWins = 0,
           TotalLoss = 0,
           Ratio = 0,
           Accuracy = 0,
           delta = 0;

    for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
    {
        if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
        if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
        if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
         
        delta = NetDelta();
         
        if( delta >= 0 )
        {
            NumWins += 1;
            TotalWins += delta;
        }
        else
        {
            NumLoss += 1;
            TotalLoss += -delta;
        }
    }

    if( NumLoss == 0 || NumWins == 0 ) return( 0 );

    AvgWin = TotalWins / NumWins;
    AvgLoss = TotalLoss / NumLoss;
    Accuracy = NumWins / ( NumWins + NumLoss );
    Ratio = AvgWin / AvgLoss;
    return( Accuracy * Ratio + Accuracy - 1 );
}

double SystemStDev( int nMagic, datetime startDate )
{
   double totalTrades = 0,
          mean = 0,
          sumX2 = 0,
          delta = 0,
          stdev = 0;
          
   mean = SystemAverageTrade( nMagic, startDate );       
          
   for( int i = OrdersHistoryTotal() ; i >= 0 ; i-- )
   {
      if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
      if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      
      
      delta = NetDelta();
      sumX2 += ( ( delta - mean ) * ( delta - mean ) ); 
      totalTrades += 1; 
   }
   
   if(totalTrades == 0)
   {
      return(0);       
   }       
   stdev = sqrt(sumX2 / totalTrades);
   return(stdev);
}

double E50( int nMagic, datetime startDate )
{
   double E50 = 10000 * SystemAverageTrade( nMagic, startDate ) * SystemTPY( nMagic, startDate );
   return(E50);
}

double MDD( int nMagic, datetime startDate)
{
   
   double   trade = 0,
            equity = 0,
            maxEquity = 0,
            drawDown = 0,
            MaxDrawDown = 0;
   
   for(  int i = 1 ; i <= OrdersHistoryTotal() ; i++  )
   {
      if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
      if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      
      
      trade = 10000*NetDelta();
      equity += trade;
      
      if(equity > maxEquity)
      {
         maxEquity = equity;
      }
      
      drawDown = maxEquity - equity;
      
      if( MaxDrawDown < drawDown )
      {
         MaxDrawDown = drawDown;
      }      
   } 
   
   return(MaxDrawDown);
}


double DD( int nMagic, datetime startDate)
{
   
   double   trade = 0,
            equity = 0,
            maxEquity = 0,
            drawDown = 0,
            MaxDrawDown = 0;
   
   for( int i = 1 ; i <= OrdersHistoryTotal() ; i++ )
   {
      if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
      if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      
      
      trade = 10000*NetDelta();
      equity += trade;
      
      if(equity > maxEquity)
      {
         maxEquity = equity;
      }
      
      drawDown = maxEquity - equity;
         
   } 
   
   return(drawDown);
}

double CAR50( int nMagic, datetime startDate, double FF = 0.1)
{

   double TPY = SystemTPY( nMagic, startDate );
   double mean = SystemAverageTrade( nMagic, startDate);

   double trade = ( 1 + FF * mean );
   double car50 = ( MathPow( trade, TPY) - 1 ) * 100;
   
   return( car50 );

}

double fixedFractionMDD( int nMagic, datetime startDate, double FF = 0.1)
{
   
   double   trade = 0,
            equity = 1,
            maxEquity = 0,
            drawDown = 0,
            MaxDrawDown = 0;
   
   for( int i = 1 ; i <= OrdersHistoryTotal() ; i++ )
   {
      if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
      if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      
      
      trade = equity * FF * NetDelta();
      equity += trade;
      
      if(equity > maxEquity)
      {
         maxEquity = equity;
      }
      
      drawDown = 100 * ( maxEquity - equity ) / equity;
      
      if( MaxDrawDown < drawDown )
      {
         MaxDrawDown = drawDown;
      }      
   } 
   
   return(MaxDrawDown);
}

double fixedFractionDD( int nMagic, datetime startDate, double FF = 0.1)
{
   
   double   trade = 0,
            equity = 1,
            maxEquity = 0,
            drawDown = 0,
            MaxDrawDown = 0;
   
   for( int i = 1 ; i <= OrdersHistoryTotal() ; i++ )
   {
      if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
      if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      
      
      trade = equity * FF * NetDelta();
      equity += trade;
      
      if(equity > maxEquity)
      {
         maxEquity = equity;
      }
      
      drawDown = 100 * ( maxEquity - equity ) / equity;     
   } 
   
   return(drawDown);
}

/*
void TradeHistoryArray( double& tradeList[], int nMagic, datetime startDate )
{
   int nTrades = TotalTradesHistory(nMagic,startDate);   
   int tradesPerYear = (int)SystemTPY(nMagic,startDate);
   
   // Create TradeList and Fill it
   ArrayResize(tradeList,nTrades,0);
   
   int j = 0;
   for( int i = 1 ; i <= OrdersHistoryTotal() ; i++ )
   {
      if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
      if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      
      tradeList[j] = NormalizeDouble(NetDelta(),5);
      j++;
   }  
}


void monteCarloRun
(
   double& TWR25_1,
   double& MDD95_1,
   double& safeF, 
   double& TWR25,
   double& MDD95,
   
   double FixedFraction,
   int nTrades,
   int tradesPerYear,
   int forcastHorizon,
   int runs,
   double dd95,
   int nMagic,
   datetime startDate
)

{   
   // Create TradeList and Fill it
   double tradeList[];
   ArrayResize(tradeList,nTrades,0);
   
   int j = 0;
   for( int i = 1 ; i <= OrdersHistoryTotal() ; i++ )
   {
      if( !OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) continue;
      if( OrderSymbol() == "" || OrderMagicNumber() != nMagic ) continue;
      if ( DateCheck(startDate, OrderCloseTime()) == false ) continue;
      
      tradeList[j] = NormalizeDouble(NetDelta(),5);      
      j++;
   }
   
   if( j < 30)
   {
      return;
   }
   
   //create TWR and MDD Arrays
   double TWR[];
   ArrayResize(TWR,runs,0);
   double MDD[];
   ArrayResize(MDD,runs,0);
   
   double fraction = FixedFraction;
   double ddTolerance = dd95;
   double twr25, mdd95;
   
   
   for( int k = 0 ; k < 10 ; k++ )
   {
      for( int a = 0 ; a < runs ; a++ )
      {
         // Set Variables for MC Run
         double equity = 1;
         double maxEquity = 1;
         double drawDown = 0;
         double MaxDrawDown = 0;
         int randomTradeNumber = 0;
         double randomTrade = 0;
         double thisTrade = 0;
         
         for( int x = 0; x < forcastHorizon*tradesPerYear; x++ )
         {
            randomTradeNumber = (int)randomBetween( 0, nTrades - 1);
            randomTrade = tradeList[randomTradeNumber];
            thisTrade = equity * fraction * randomTrade;
            equity = equity + thisTrade;
            maxEquity = MathMax(equity,maxEquity);
            drawDown = (maxEquity - equity) / maxEquity;
            MaxDrawDown = MathMax(drawDown,MaxDrawDown);      
         }
         
         //Print(a);      
         
         TWR[a] = equity;
         MDD[a] = MaxDrawDown;    
         //Sleep(1);        
      }
      
      ArraySort(TWR);
      ArraySort(MDD);
      
      int P25 = (int)MathFloor(0.25 * runs);
      int P95 = (int)MathFloor(0.99 * runs);    
            
      twr25 = TWR[P25];
      mdd95 = MDD[P95];
      
      if( k == 0 )
      {
         TWR25_1 = twr25;
         MDD95_1 = 100*mdd95;         
      }
      
      if( MathAbs(mdd95 - ddTolerance) > 0.005 && mdd95 != 0)
      {
         fraction = fraction * ddTolerance / mdd95;
         Print(k);
         continue;
      }
      else
      {
         safeF = fraction;
         TWR25 = twr25;
         MDD95 = 100 * mdd95;
         break;         
      }      
   }      
}

double SystemTTest( int nMagic, datetime startDate )
{
   double stdev = SystemStDev( nMagic, startDate ),
          t = 0;
          
   if (stdev == 0) return(0);  
   
   t = SystemAverageTrade( nMagic, startDate ) / stdev  * sqrt( TotalTradesHistory( nMagic, startDate ) );
   return (t);
}



/*
int MarketOpenTime( string symbol )
{
    for( int i = 1; i <= 300; i++ )
    {
        if( TimeDay( iTime( symbol, PERIOD_M5, i ) ) != TimeDay( iTime( symbol, PERIOD_M5, i - 1 ) ) )
        {
            int H = TimeHour( iTime( symbol, PERIOD_M5, i - 1 ) );
            int M = TimeMinute( iTime( symbol, PERIOD_M5, i - 1 ) );
            int TimeCurrentBar = H * 100 + M;

            return( TimeCurrentBar );
        }
    }

    return( 0 );
}


int MarketCloseTime( string symbol )
{
    for( int i = 1; i <= 300; i++ )
    {
        if( TimeDay( iTime( symbol, PERIOD_M5, i ) ) != TimeDay( iTime( symbol, PERIOD_M5, i - 1 ) ) )
        {
            int H = TimeHour( iTime( symbol, PERIOD_M5, i ) );
            int M = TimeMinute( iTime( symbol, PERIOD_M5, i ) );
            int TimeCurrentBar = H * 100 + M;

            return( TimeCurrentBar );
        }
    }

    return( 0 );
}


bool MarketClosingWindow( string symbol, int TimeLimit )
{
    int TC = 100 * TimeHour( TimeCurrent() ) + TimeMinute( TimeCurrent() );

    if( TC >= MarketCloseTime( symbol ) && TC <= MarketCloseTime( symbol ) + TimeLimit )
    {
        return( true );
    }
    else
    {
        return( false );
    }
}

double SymbolToUSD(string symbol)
{
    string BASE = SymbolInfoString( symbol, SYMBOL_CURRENCY_BASE );
    double BASEUSD = iClose( BASE + "USD", PERIOD_D1, 0 );
    double USDBASE = iClose( "USD" + BASE, PERIOD_D1, 0 );
    double M = 0;

    if( BASE == "USD" )
    {
        return( 1 );
    }

    if( BASE == "GBP" )
    {
        if( BASEUSD != 0 )
            return( 100 / BASEUSD );
        else
            return( 0 );
    }

    if( BASEUSD != 0 || USDBASE != 0 )
    {
        if( BASEUSD != 0 )
        {
            return( 1 / BASEUSD );
        }

        if( USDBASE != 0 )
        {
            return( USDBASE );
        }
    }

    return( 0 );
}
*/