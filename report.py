from fastapi import APIRouter, Header, Path, HTTPException, status, Depends
from datetime import date, timedelta
from typing import List, Dict, Any, Optional

from models import Table, Column, Row, Cell

from db import PostgresConnector
from dependencies import get_database

from pathlib import Path

import os

from models import (
    RescueNetworkReport,
    RescueSurrendersDrilldown,
    Rescue60DayAdoptionsDrilldown,
    MonthlyAdoptionReport,
    ExpenseAnalysisReport,
    VolunteerLookupReport,
    VolunteerAnniversaryReport,
	)

router = APIRouter()

# helper function to load SQL queries from queries folder
def load_sql_query(file_name: str) -> str:
	script_dir = os.path.dirname(__file__)
	file_path = os.path.join(script_dir,"queries", file_name)
	try:
		with open(file_path, 'r') as f:
			return f.read()
	except FileNotFoundError:
		raise HTTPException(
			status_code = status.HTTP_500_INTERNAL_SERVER_ERROR,
			detail=f"SQL query file not found: {file_path}"
		)


# reports endpoints

@router.get("/reports/rescue-network",response_model=RescueNetworkReport, status_code=status.HTTP_200_OK)
def rescue_netwrok_report(db: PostgresConnector = Depends(get_database)):
	get_query = load_sql_query("get_rescue_network_report.sql")
	res: List[Dict[str,Any]] = db.fetch(get_query)
	return RescueNetworkReport(rows=res)

@router.get("/reports/rescue-network/{month}/surrenders", response_model=RescueSurrendersDrilldown, status_code=status.HTTP_200_OK)
def surrender_report(
	month: int = Path(...,ge=1,le=12, description="Month(1-12) for the surrender drilldown"),
	year: int = Query(..., description="Year for the surrender drilldown"),
	db: PostgresConnector = Depends(get_database)
):

	get_query = load_sql_query("report_rescue_network_surrenders_drilldown.sql")

	start_date = date(year,month,1)
	end_date = (start_date + timedelta(days=32)).replace(day=1) - timedelta(days=1)

	res: List[Dict[str, Any]] = db.fetch(get_query,(start_date,end_date))
	return RescueSurrendersDrilldown(rows=res)

@router.get("/reports/rescue-network/{month}/60-day", response_model=Rescue60DayAdoptionsDrilldown, status_code=status.HTTP_200_OK)
def rescue_network_60day_report(
    month: int = Path(..., ge=1, le=12, description="Month (1-12) for the 60-day adoption drilldown"),
    year: int = Query(..., description="Year for the 60-day adoption drilldown"),
    db: PostgresConnector = Depends(get_database)
):

	get_query = load_sql_query("report_rescue_network_60day.sql")
	start_date = date(year, month, 1)
	end_date = (start_date + timedelta(days=32)).replace(day=1) - timedelta(days=1)

	res: List[Dict[str, Any]] = db.fetch(get_query, (start_date, end_date))
    return Rescue60DayAdoptionsDrilldown(rows=res)

@router.get("/reports/monthly-adoption", response_model=MonthlyAdoptionReport, status_code=status.HTTP_200_OK)
def monthly_adoption_by_month_report(
    db: PostgresConnector = Depends(get_database)
):

	get_query = load_sql_query("get_monthly_adoption_report.sql")
	res: List[Dict[str, Any]] = db.fetch(get_query)
    return MonthlyAdoptionReport(rows=res)

@router.get("/reports/expense-analysis", response_model=ExpenseAnalysisReport, status_code=status.HTTP_200_OK)
def expense_analysis_report(db: PostgresConnector = Depends(get_database)):
	get_query = load_sql_query("get_expense_analysis_report.sql")
    res: List[Dict[str, Any]] = db.fetch(get_query)
    return ExpenseAnalysisReport(rows=res)

@router.get("/reports/volunteer-lookup", response_model=VolunteerLookupReport, status_code=status.HTTP_200_OK)
def volunteer_lookup_report(
    search_string: Optional[str] = Query(None, description="Optional search string for first/last name"),
    db: PostgresConnector = Depends(get_database)
):

	get_query = load_sql_query("search_volunteers.sql")
	effective_search_string = f"%{search_string.lower()}%" if search_string else "%%"

	res: List[Dict[str, Any]] = db.fetch(get_query, (effective_search_string, effective_search_string))
	return VolunteerLookupReport(rows=res)

@router.get("/reports/volunteer-anniversary/{year}/{month}", response_model=VolunteerAnniversaryReport, status_code=status.HTTP_200_OK)
def volunteer_anniversary_report(
    year: int = Path(..., description="Year for the anniversary report"),
    month: int = Path(..., ge=1, le=12, description="Month (1-12) for the anniversary report"),
    db: PostgresConnector = Depends(get_database)
):

	get_query = load_sql_query("get_volunteer_anniversaries.sql")
	target_date = date(year,month,1)

	res: List[Dict[str, Any]] = db.fetch(get_query, (target_date, target_date, month, year))	
	return VolunteerAnniversaryReport(rows=res)