from sqlalchemy import Column, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class ServiceRecordModel(Base):
    __tablename__ = "service_records"
    id = Column(String, primary_key=True)
    external_ref = Column(String)
    status = Column(String)
    metadata_json = Column(String)
    created_at = Column(String)
    updated_at = Column(String)

class AuditEventModel(Base):
    __tablename__ = "audit_events"
    event_id = Column(String, primary_key=True)
    record_id = Column(String)
    actor_id = Column(String)
    action_type = Column(String)
    created_at = Column(String)

